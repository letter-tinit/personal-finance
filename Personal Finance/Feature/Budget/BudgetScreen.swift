//
//  ContentView.swift
//  Personal Finance
//
//  Created by TiniT on 9/7/26.
//

import SwiftUI

struct BudgetScreen: View {
    @State private var title: String = "salary.budget".localized
    @State private var viewModel: BudgetDetailViewModel
    @State private var segmentOption: SegmentOption = .overview
    @State private var isFixedPlanPresented = false
    @State private var isTransactionFormPresented = false
    @State private var selectedTransaction: BudgetTransaction?
    @State private var transactionPendingDeletion: BudgetTransaction?
    @State private var isDeleteConfirmationPresented = false
    @State private var isDeleteErrorPresented = false

    private var budget: Budget { viewModel.budget }

    init(_ viewModel: BudgetDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    private var transactionGroups: [TransactionGroup] {
        Dictionary(grouping: budget.transactions) {
            Calendar.current.startOfDay(for: $0.occurredAt)
        }
        .map { date, transactions in
            TransactionGroup(
                date: date,
                transactions: transactions.sorted { $0.occurredAt > $1.occurredAt }
            )
        }
        .sorted { $0.date > $1.date }
    }

    var body: some View {
        BaseScreen($title) {
            VStack {
                BudgetIncomeView(budget: budget)

                Picker("budget.view.mode".localized, selection: $segmentOption) {
                    ForEach(SegmentOption.allCases, id: \.self) { option in
                        Text(option.localizationKey.localized)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .padding(.top)

                if segmentOption == .overview {
                    AppScrollView(.vertical) {
                        VStack {
                            ForEach(budget.allocations) { allocation in
                                BudgetAllocationView(summary: budget.allocationSummary(for: allocation))
                            }
                        }
                    }
                    .padding(.top)
                } else {
                    transactionList
                }
            }
            .padding()
        }
        .onAppear {
            title = budget.name
        }
        .sheet(isPresented: $isFixedPlanPresented) {
            NavigationStack {
                FixedPlanView(
                    plans: budget.fixedExpensePlans,
                    onAdd: addFixedExpensePlan,
                    onUpdate: updateFixedExpensePlan,
                    onDelete: deleteFixedExpensePlan,
                    onComplete: completeFixedExpensePlan
                )
            }
        }
        .sheet(isPresented: $isTransactionFormPresented) {
            NavigationStack {
                TransactionFormView(
                    allocations: budget.allocations,
                    onSave: addTransaction
                )
            }
        }
        .sheet(item: $selectedTransaction) { transaction in
            NavigationStack {
                TransactionFormView(
                    allocations: budget.allocations,
                    initialState: TransactionFormState(transaction: transaction),
                    titleKey: "transaction.form.edit.title",
                    onSave: { input in
                        viewModel.updateTransaction(transaction, input: input)
                    },
                    onDelete: {
                        viewModel.deleteTransaction(transaction)
                    }
                )
            }
        }
        .deleteConfirmationDialog(
            isPresented: $isDeleteConfirmationPresented,
            title: "transaction.form.delete.confirmation.title".localized,
            message: "common.delete.warning".localized
        ) {
            deletePendingTransaction()
        } cancelAction: {
            transactionPendingDeletion = nil
        }
        .alert(
            "transaction.form.error.delete".localized,
            isPresented: $isDeleteErrorPresented
        ) {
            Button("common.ok".localized, role: .cancel) {}
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    isFixedPlanPresented = true
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel("fixed.plan.title".localized)

                Button {
                    isTransactionFormPresented = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("transaction.form.add".localized)
            }
        }
    }
}

private extension BudgetScreen {
    @ViewBuilder
    var transactionList: some View {
        if budget.transactions.isEmpty {
            ContentUnavailableView(
                "budget.transactions.empty".localized,
                systemImage: "list.bullet.rectangle"
            )
        } else {
            List {
                ForEach(transactionGroups) { group in
                    Section {
                        ForEach(group.transactions) { transaction in
                            Button {
                                selectedTransaction = transaction
                            } label: {
                                BudgetTransactionRow(
                                    transaction: transaction,
                                    allocation: budget.allocation(for: transaction)
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityHint("transaction.edit.accessibilityHint".localized)
                            .swipeActions(edge: .trailing) {
                                Button {
                                    transactionPendingDeletion = transaction
                                    isDeleteConfirmationPresented = true
                                } label: {
                                    Label("common.delete".localized, systemImage: "trash")
                                }
                                .tint(Color.Common.failure)
                            }
                        }
                    } header: {
                        Text(group.date.toString(withFormat: .dayNameWithNo))
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .padding(.horizontal, -16)
        }
    }

    func addFixedExpensePlan(_ input: ValidatedFixedExpensePlanInput) throws {
        viewModel.addFixedExpensePlan(input)
    }

    func updateFixedExpensePlan(planID: UUID, input: ValidatedFixedExpensePlanInput) throws {
        guard let plan = budget.fixedExpensePlans.first(where: { $0.id == planID }) else {
            throw BudgetError.fixedExpensePlanNotFound
        }
        viewModel.updateFixedExpensePlan(plan, input: input)
    }

    func deleteFixedExpensePlan(_ planID: UUID) throws {
        guard let plan = budget.fixedExpensePlans.first(where: { $0.id == planID }) else {
            throw BudgetError.fixedExpensePlanNotFound
        }
        viewModel.deleteFixedExpensePlan(plan)
    }

    func completeFixedExpensePlan(planID: UUID, input: ValidatedBudgetTransactionInput) throws {
        guard let plan = budget.fixedExpensePlans.first(where: { $0.id == planID }) else {
            throw BudgetError.fixedExpensePlanNotFound
        }
        viewModel.completeFixedExpensePlan(plan, input: input)
    }

    func addTransaction(_ input: ValidatedBudgetTransactionInput) throws {
        viewModel.addTransaction(input)
    }

    func deletePendingTransaction() {
        guard let transactionPendingDeletion else { return }
        viewModel.deleteTransaction(transactionPendingDeletion)
        self.transactionPendingDeletion = nil
        if viewModel.toastMessage != nil {
            isDeleteErrorPresented = true
        }
    }
}

struct BudgetIncomeView: View {
    let budget: Budget

    var body: some View {
        VStack(alignment: .leading) {
            Text("monthly.salary".localized)
                .customSubHeadline()
                .foregroundStyle(.secondary)

            Text(budget.income.formattedVND)
                .customTitle()
                .foregroundStyle(.primary)

            Divider()
                .padding(.horizontal, -16)

            HStack {
                Text("budget.method".localized)
                    .customHeadline()
                    .foregroundStyle(.secondary)

                Spacer()

                Text(budget.method.localizationKey.localized)
                    .customSubHeadline()
                    .foregroundStyle(.tint)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().foregroundStyle(.tint.opacity(0.12)))
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .borderedBackground(linearGradient: LinearGradient(
            colors: [
                .green.opacity(0.55),
                .cyan.opacity(0.4),
                .green.opacity(0.25)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ))
    }
}

struct BudgetAllocationView: View {
    let summary: BudgetAllocationSummary

    private var allocation: BudgetAllocation { summary.allocation }
    private var isSaving: Bool { allocation.kind.isSavingsLike }
    private var planRatioText: String { "\((summary.planRatio.doubleValue * 100).ceiledToTwoDecimalPlaces)%" }
    private var actualRatioText: String { "\((summary.actualRatio.doubleValue * 100).ceiledToTwoDecimalPlaces)%" }
    private var differenceAmount: Decimal { summary.remainingAmount < 0 ? -summary.remainingAmount : summary.remainingAmount }
    private var differenceTitle: String {
        summary.remainingAmount < 0
        ? "budget.metric.overTarget".localized
        : (isSaving ? "budget.metric.remainingToSave".localized : "budget.metric.remaining".localized)
    }
    private let topOffset: CGFloat = 20

    var body: some View {
        VStack(alignment: .leading) {
            CommonRowView(.init(title: "budget.metric.target".localized, value: allocation.targetAmount.formattedVND))
            CommonRowView(.init(
                title: isSaving ? "budget.metric.saved".localized : "budget.metric.spent".localized,
                value: summary.actualAmount.formattedVND
            ))
            Divider()
            CommonRowView(.init(title: "budget.metric.planRatio".localized, value: planRatioText))
            CommonRowView(.init(title: "budget.metric.actualRatio".localized, value: actualRatioText))
            Divider()
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(differenceTitle)
                        .secondarySubHeadline()
                    Text(differenceAmount.formattedVND)
                        .customTitle()
                }

                Spacer()

                statusBadge
            }
            progressBar
        }
        .padding()
        .padding(.top, 6)
        .frame(maxWidth: .infinity)
        .borderedBackground(
            linearGradient: LinearGradient(
                colors: [
                    allocation.kind.topicColor.opacity(0.3),
                    allocation.kind.topicColor.opacity(0.2),
                    allocation.kind.topicColor.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(alignment: .top) {
            HStack(spacing: 6) {
                Image(systemName: allocation.kind.systemImageName)
                Text(allocation.kind.localizationKey.localized)
            }
            .customHeadline()
            .foregroundStyle(.white)
            .padding(8)
            .padding(.horizontal, 16)
            .background(Capsule().foregroundStyle(allocation.kind.topicColor))
            .offset(y: -topOffset)
        }
        .padding(.top, topOffset)
    }

    private var statusBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: summary.status.systemImageName)
            Text(summary.status.localizationKey.localized)
        }
        .customSubHeadline()
        .foregroundStyle(summary.status.tintColor(for: allocation.kind))
    }

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Color.gray.opacity(0.2)
                allocation.kind.topicColor
                    .clipShape(.capsule)
                    .frame(width: geometry.size.width * summary.displayBarProgress)
            }
        }
        .frame(height: 10)
        .clipShape(.capsule)
    }
}

private extension BudgetAllocationStatus {
    var localizationKey: String {
        switch self {
        case .ok: "budget.status.ok"
        case .over: "budget.status.over"
        case .done: "budget.status.done"
        case .needMore: "budget.status.needMore"
        }
    }

    var systemImageName: String {
        switch self {
        case .ok, .done: "checkmark.circle.fill"
        case .over: "exclamationmark.circle.fill"
        case .needMore: "circle"
        }
    }

    func tintColor(for kind: BudgetBucketKind) -> Color {
        switch self {
        case .ok, .done: kind.topicColor
        case .over: Color.Common.failure
        case .needMore: Color.secondary
        }
    }
}

struct BudgetTransactionRow: View {
    let transaction: BudgetTransaction
    let allocation: BudgetAllocation?

    private var formattedAmount: String {
        let sign = transaction.type == .income ? "+" : "-"
        return sign + transaction.amount.formattedVND
    }

    private var amountColor: Color {
        transaction.type == .income ? Color.Common.success : Color.Common.failure
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(transaction.title)
                    .secondarySubHeadline()

                Spacer()

                Text(formattedAmount)
                    .customSubTitle()
                    .foregroundStyle(amountColor)
            }

            if let allocation {
                HStack(spacing: 6) {
                    Text(allocation.kind.localizationKey.localized)
                        .foregroundStyle(allocation.kind.topicColor)

                    Text("•")

                    Text(transaction.paymentMethod.localizationKey.localized)
                        .foregroundStyle(.secondary)
                }
                .customHeadline()
            } else {
                Text("budget.allocation.unknown".localized)
                    .customHeadline()
                    .foregroundStyle(.secondary)
            }

            if !transaction.note.isEmpty {
                Text(transaction.note)
                    .secondarySubHeadline()
            }
        }
        .frame(maxWidth: .infinity)
    }
}

extension BudgetScreen {
    struct TransactionGroup: Identifiable {
        let date: Date
        let transactions: [BudgetTransaction]
        var id: Date { date }
    }

    enum SegmentOption: CaseIterable, Hashable {
        case overview
        case transaction

        var localizationKey: String {
            switch self {
            case .overview: "budget.segment.overview"
            case .transaction: "budget.segment.transactions"
            }
        }
    }
}
