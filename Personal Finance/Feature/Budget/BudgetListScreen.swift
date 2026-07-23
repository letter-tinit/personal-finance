//
//  BudgetListScreen.swift
//  Personal Finance
//
//  Created by TiniT on 13/7/26.
//

import SwiftUI

struct BudgetListScreen: View {
    @Environment(BudgetRouter.self) private var router
    @State private var title: String = "salary.budget".localized
    @State private var viewModel: BudgetViewModel
    @State private var isCreateBudgetPresented = false
    @State private var isDeleteConfirmationPresented = false
    @State private var budgetToDelete: Budget? {
        didSet {
            isDeleteConfirmationPresented = true
        }
    }
    
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
        BaseScreen($title) {
            Group {
                if budgets.isEmpty {
                    ContentUnavailableView(
                        "budget.list.empty".localized,
                        systemImage: "calendar.badge.plus",
                        description: Text("budget.list.empty.description".localized)
                    )
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
                    .scrollContentBackground(.hidden)
                    .listStyle(.insetGrouped)
                }
            }
        }
        .deleteConfirmationDialog(
            isPresented: $isDeleteConfirmationPresented,
            title: "budget.delete.title".localized,
            message: "common.delete.warning".localized
        ) {
            deleteBudget()
        }
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
        .toast(message: viewModel.toastMessage)
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

#Preview {
    // TODO
    //    BudgetListScreen()
}
