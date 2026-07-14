//
//  FixedPlanView.swift
//  Personal Finance
//
//  Created by TiniT on 14/7/26.
//

import SwiftUI

struct FixedPlanView: View {
    let plans: [FixedExpensePlan]

    private var totalAmount: Decimal {
        plans.reduce(.zero) { partialResult, plan in
            partialResult + plan.amount
        }
    }

    var body: some View {
        List {
            if plans.isEmpty {
                emptyView
            } else {
                ForEach(plans, id: \.self) { plan in
                    CommonRowView(
                        .init(
                            title: plan.name,
                            value: plan.amount.formattedVND
                        )
                    )
                }
            }
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .top, spacing: 0) {
            totalSection
        }
    }
}

// MARK: - Subviews

private extension FixedPlanView {
    var totalSection: some View {
        CommonRowView(
            .init(
                title: "fixed.plan.total".localized,
                value: totalAmount.formattedVND,
                isHighlight: true
            )
        )
        .padding()
        .padding(.top)
        .background(
            Color(uiColor: .secondarySystemGroupedBackground)
                .overlay(BudgetBucketKind.needs.topicColor.opacity(0.12))
        )
    }

    var emptyView: some View {
        ContentUnavailableView {
            Label(
                "fixed.plan.empty.title".localized,
                systemImage: "list.bullet.rectangle"
            )
        } description: {
            Text("fixed.plan.empty.description".localized)
        }
    }
}

// MARK: - Preview

#Preview {
    FixedPlanView(
        plans: Budget.mock.fixedExpensePlans
    )
}
