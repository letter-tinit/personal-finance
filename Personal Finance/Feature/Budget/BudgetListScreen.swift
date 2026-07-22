//
//  BudgetListScreen.swift
//  Personal Finance
//
//  Created by TiniT on 13/7/26.
//

import SwiftUI

struct BudgetListScreen: View {
    @Environment(BudgetRouter.self) private var router
    @State private var viewModel: BudgetViewModel
    @State private var errorMessage: String?
    @State private var isCreateBudgetPresented = false
    @State private var isDeleteConfirmationPresented = false
    @State private var budgetToDelete: Budget?
    
    private var budgets: [Budget] {
        viewModel.budgets
    }
    
    init(_ viewModel: BudgetViewModel) {
        self.viewModel = viewModel
    }

    private var latestBudget: Budget? {
        budgets.max { first, second in
            first.periodStart < second.periodStart
        }
    }

    var body: some View {
            Group {
                if budgets.isEmpty {
                    VStack(spacing: 12) {
                        ContentUnavailableView(
                            "budget.list.empty".localized,
                            systemImage: "calendar.badge.plus",
                            description: Text("budget.list.empty.description".localized)
                        )

                        if let errorMessage {
                            Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                                .font(.footnote)
                                .foregroundStyle(Color.Common.failure)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                } else {
                    List(sortedBudgetGroupByYear()) { section in
                        Section(String(describing: section.year)) {
                            ForEach(section.budgets, id: \.self) { budget in
                                Button {
                                    router.push(.budget(budget))
                                } label: {
                                    BudgetListRow(budget: budget)
                                }
                                .buttonStyle(.plain)
                                .swipeActions {
                                    Button {
                                        budgetToDelete = budget
                                        isDeleteConfirmationPresented = true
                                    } label: {
                                        VStack {
                                            Text("common.delete".localized)
                                                .secondarySubHeadline()
                                            
                                            Image(module: "trash")
                                                .tint(.red)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .safeAreaInset(edge: .bottom) {
                        if let errorMessage {
                            Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                                .font(.footnote)
                                .foregroundStyle(Color.Common.failure)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(.regularMaterial)
                        }
                    }
                }
            }
            .confirmationDialog(
                "budget.delete.title".localized,
                isPresented: $isDeleteConfirmationPresented,
                titleVisibility: .visible
            ) {
                Button(
                    "common.delete".localized,
                    role: .destructive
                ) {
                    deleteBudget()
                }
            } message: {
                Text("common.delete.warning".localized)
            }
            .navigationTitle("salary.budget".localized)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isCreateBudgetPresented = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("budget.create.title".localized)
                }
            }
            .sheet(isPresented: $isCreateBudgetPresented) {
                NavigationStack {
                    CreateBudgetView(
                        existingBudgets: budgets,
                        templateBudget: latestBudget
                    )
                    .environment(viewModel)
                }
            }
            .task {
                viewModel.load()
            }
    }
}

private extension BudgetListScreen {
    private func getBudget(offset: IndexSet, section: BudgetYearSection) -> Budget? {
        let idsToDelete = offset.map { index in
            section.budgets[index].id
        }
        
        return budgets.first { idsToDelete.contains($0.id) }
    }
    
    private func sortedBudgetGroupByYear() -> [BudgetYearSection] {
        let grouped = Dictionary(grouping: budgets) { budget in
            Calendar.current.component(.year, from: budget.periodStart)
        }
        
        return grouped
            .map { year, budgets in
                BudgetYearSection(
                    year: year,
                    budgets: budgets.sorted(by: { $0.periodStart > $1.periodStart })
                )
            }
            .sorted { $0.year > $1.year }
    }

    private func deleteBudget() {
        guard let budgetToDelete else { return }
        viewModel.deleteBudget(budgetToDelete)
        self.budgetToDelete = nil
    }
    
    struct BudgetYearSection: Identifiable, Hashable {
        let year: Int
        let budgets: [Budget]

        var id: Int { year }
    }
}

private struct BudgetListRow: View {
    let budget: Budget

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(budget.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(budget.method.localizationKey.localized)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(budget.income.formattedVND)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    // TODO
//    BudgetListScreen()
}
