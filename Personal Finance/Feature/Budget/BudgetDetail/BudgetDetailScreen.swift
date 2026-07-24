//
//  BudgetDetailScreen.swift
//  Personal Finance
//
//  Created by TiniT on 9/7/26.
//

import SwiftUI

struct BudgetDetailScreen: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    private var isPortrait: Bool {
        verticalSizeClass == .regular
    }
    
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
                Group {
                    if isPortrait {
                        BudgetIncomeCardView(budget: budget, isPortrait: isPortrait)
                        
                        BudgetSengmentSelectionView(selectedSegment: $segmentOption)
                            .padding(.top)
                    }
                }
                .padding(.horizontal)
                
                content
            }
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
        .onChange(of: transactionPendingDeletion) { _, newValue in
            if newValue != nil {
                isDeleteConfirmationPresented = true
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
            ToolbarItem(placement: .topBarTrailing) {
                if !isPortrait {
                    BudgetIncomeCardView(budget: budget, isPortrait: isPortrait)
                }
            }
            .sharedBackgroundVisibility(.hidden)
            
            ToolbarItem(placement: .topBarTrailing) {
                if !isPortrait {
                    BudgetSengmentSelectionView(selectedSegment: $segmentOption)
                        .frame(width: 240)
                }
            }
            .sharedBackgroundVisibility(.hidden)
            
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

private extension BudgetDetailScreen {
    @ViewBuilder
    var content: some View {
        if segmentOption == .overview {
            BudgetAllocationListView(budget: budget)
        } else {
            groupTransactionList
        }
    }
    
    @ViewBuilder
    var groupTransactionList: some View {
        if budget.transactions.isEmpty {
            CommonEmptyView(
                systemImage: "list.bullet.rectangle",
                description: "budget.transactions.empty".localized
            )
        } else {
            AppScrollView {
                ForEach(transactionGroups) { group in
                    BudgetTransactionGroupRow(
                        group: group,
                        selectedTransaction: $selectedTransaction,
                        transactionPendingDeletion: $transactionPendingDeletion
                    )
                }
                .padding()
            }
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

extension BudgetDetailScreen {
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
