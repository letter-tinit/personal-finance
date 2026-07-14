//
//  ContentView.swift
//  Personal Finance
//
//  Created by TiniT on 9/7/26.
//

import SwiftUI

struct BudgetScreen: View {
    let budget: Budget
    
    @State private var segmentOption: SegmentOption = .overview
    
    private var transactionGroups: [TransactionGroup] {
        let groups = Dictionary(grouping: budget.transactions) {
            Calendar.current.startOfDay(for: $0.occurredAt)
        }
        
        return groups
            .map { date, transactions in
                TransactionGroup(
                    date: date,
                    transactions: transactions.sorted {
                        $0.occurredAt > $1.occurredAt
                    }
                )
            }
            .sorted { $0.date > $1.date }
    }
    
    var body: some View {
        BaseScreen {
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
                
                AppScrollView(.vertical) {
                    if segmentOption == .overview {
                        VStack {
                            ForEach(budget.allocations) { allocation in
                                BudgetAllocationView(
                                    allocation: allocation,
                                    actualAmount: budget.actualAmount(for: allocation)
                                )
                            }
                        } // OVERVIEW STACK
                    } else {
                        if budget.transactions.isEmpty {
                            Text("budget.transactions.empty".localized)
                                .secondarySubHeadline()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 32)
                        } else {
                            LazyVStack(alignment: .leading, spacing: 16) {
                                ForEach(transactionGroups) { group in
                                    Text(group.date.toString(withFormat: .dayNameWithNo))
                                        .customSubTitle()
                                    
                                    ForEach(group.transactions) { transaction in
                                        BudgetTransactionRow(
                                            transaction: transaction,
                                            allocation: budget.allocation(for: transaction)
                                        )
                                    }
                                }
                            }
                        }
                    } // TRANSACTION STACK
                    
                    Spacer()
                }
                .padding(.top)
            }
            .padding()
            .navigationTitle(budget.name)
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
                    .background(
                        Capsule()
                            .foregroundStyle(.tint.opacity(0.12))
                    )
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
    let allocation: BudgetAllocation
    let actualAmount: Decimal
    
    private var remainingAmount: Decimal {
        allocation.targetAmount - actualAmount
    }
    
    private var isSaving: Bool {
        allocation.kind.isSavingsLike
    }
    
    private var isSavingCompleted: Bool {
        actualAmount >= allocation.targetAmount
    }
    
    private var remainingProgress: Decimal {
        guard allocation.targetAmount > 0 else {
            return remainingAmount > 0 ? 1 : .zero
        }
        
        return remainingAmount / allocation.targetAmount
    }
    
    private var displayProgress: Double {
        min(max(remainingProgress.doubleValue, 0), 1)
    }
    
    private var progressText: String {
        "\((displayProgress * 100).ceiledToTwoDecimalPlaces)%"
    }
    
    private let topOffset: CGFloat = 20
    
    var body: some View {
        VStack(alignment: .leading) {
            CommonRowView(
                .init(title: "budget.metric.target".localized, value: allocation.targetAmount.formattedVND)
            )
            
            CommonRowView(
                .init(
                    title: isSaving
                    ? "budget.metric.saved".localized
                    : "budget.metric.spent".localized,
                    value: actualAmount.formattedVND
                )
            )
            
            Divider()
            
            HStack {
                Text(remainingAmount.formattedVND)
                    .customTitle()
                
                Spacer()
                
                if isSaving {
                    savingsStatusBadge
                } else {
                    Text(progressText)
                        .customSubHeadline()
                }
            }
            
            if !isSaving {
                progressBar
            }
        }
        .padding()
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
            Text(allocation.kind.localizationKey.localized)
                .customHeadline()
                .foregroundStyle(.white)
                .padding(8)
                .padding(.horizontal, 16)
                .background(
                    Capsule()
                        .foregroundStyle(allocation.kind.topicColor)
                )
                .offset(y: -topOffset)
        }
        .padding(.top, topOffset)
    }
    
    private var savingsStatusBadge: some View {
        HStack(spacing: 4) {
            Image(
                systemName: isSavingCompleted
                ? "checkmark.circle.fill"
                : "circle"
            )
            Text(
                isSavingCompleted
                ? "budget.status.done".localized
                : "budget.status.pending".localized
            )
        }
        .customSubHeadline()
        .foregroundStyle(
            isSavingCompleted
            ? allocation.kind.topicColor
            : Color.secondary
        )
    }
    
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Color.gray
                    .opacity(0.2)
                
                allocation.kind.topicColor
                    .clipShape(.capsule)
                    .frame(width: geometry.size.width * displayProgress)
            }
        }
        .frame(height: 10)
        .clipShape(.capsule)
    }
}

struct BudgetTransactionRow: View {
    let transaction: BudgetTransaction
    let allocation: BudgetAllocation?
    
    private var formattedAmount: String {
        let sign = transaction.type == .contribution ? "+" : "-"
        return sign + transaction.amount.formattedVND
    }
    
    private var amountColor: Color {
        transaction.type == .contribution
        ? Color.Common.success
        : Color.Common.failure
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(transaction.note)
                    .secondarySubHeadline()
                
                Spacer()
                
                Text(formattedAmount)
                    .customSubTitle()
                    .foregroundStyle(amountColor)
            }
            
            if let allocation {
                Text(allocation.kind.localizationKey.localized)
                    .customHeadline()
                    .foregroundStyle(allocation.kind.topicColor)
            } else {
                Text("budget.allocation.unknown".localized)
                    .customHeadline()
                    .foregroundStyle(.secondary)
            }
            
            Divider()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    BudgetScreen(budget: .mock)
}

// MARK: - Enum
extension BudgetScreen {
    struct TransactionGroup: Identifiable {
        let date: Date
        let transactions: [BudgetTransaction]
        
        var id: Date {
            date
        }
    }
    
    enum SegmentOption: CaseIterable, Hashable {
        case overview
        case transaction
        
        var localizationKey: String {
            switch self {
            case .overview:
                "budget.segment.overview"
            case .transaction:
                "budget.segment.transactions"
            }
        }
    }
}

private extension BudgetBucketKind {
    var isSavingsLike: Bool {
        switch self {
        case .savings, .financialFreedom, .longTermSavings:
            true
        default:
            false
        }
    }
}
