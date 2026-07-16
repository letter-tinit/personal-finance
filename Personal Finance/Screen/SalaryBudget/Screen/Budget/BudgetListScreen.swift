//
//  BudgetListScreen.swift
//  Personal Finance
//
//  Created by TiniT on 13/7/26.
//

import SwiftUI

struct BudgetListScreen: View {
    @State private var budgetRouter = BudgetRouter()
    @State private var budgets: [Budget] = []
    @State private var isCreateBudgetPresented = false
    @State private var errorMessage: String?
    @State private var hasLoadedBudgets = false

    private let budgetStore: BudgetStore?
    init(budgetStore: BudgetStore? = try? BudgetStore()) {
        self.budgetStore = budgetStore
    }

    private var latestBudget: Budget? {
        budgets.max { first, second in
            first.periodStart < second.periodStart
        }
    }

    var body: some View {
        AppNavigationStack(path: $budgetRouter.path) {
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
                                    budgetRouter.push(.budget(budget.id))
                                } label: {
                                    BudgetListRow(budget: budget)
                                }
                                .buttonStyle(.plain)
                            }
                            .onDelete { indexSet in
                                deleteBudget(offset: indexSet, section: section)
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
                        templateBudget: latestBudget,
                        onCreate: createBudget
                    )
                }
            }
            .task {
                loadBudgetsIfNeeded()
            }
            .onChange(of: budgets) {
                guard hasLoadedBudgets else {
                    return
                }

                saveBudgets()
            }
        } destination: { route in
            switch route {
            case .budget(let budgetID):
                if let budgetBinding = binding(for: budgetID) {
                    BudgetScreen(budget: budgetBinding)
                } else {
                    ContentUnavailableView(
                        "budget.detail.missing".localized,
                        systemImage: "exclamationmark.triangle"
                    )
                }
            }
        }
    }
}

private extension BudgetListScreen {
    func binding(for budgetID: UUID) -> Binding<Budget>? {
        guard let index = budgets.firstIndex(where: { $0.id == budgetID }) else {
            return nil
        }

        return $budgets[index]
    }

    func createBudget(_ budget: Budget) {
        budgets.append(budget)
        budgetRouter.push(.budget(budget.id))
    }

    func loadBudgetsIfNeeded() {
        guard !hasLoadedBudgets else {
            return
        }

        hasLoadedBudgets = true

        guard let budgetStore else {
            errorMessage = "budget.storage.error.load".localized
            return
        }

        do {
            budgets = try budgetStore.loadBudgets()
            errorMessage = nil
        } catch {
            budgets = []
            errorMessage = "budget.storage.error.load".localized
        }
    }

    func saveBudgets() {
        guard let budgetStore else {
            errorMessage = "budget.storage.error.save".localized
            return
        }

        do {
            try budgetStore.saveBudgets(budgets)
            errorMessage = nil
        } catch {
            errorMessage = "budget.storage.error.save".localized
        }
    }
    
    private func deleteBudget(offset: IndexSet, section: BudgetYearSection) {
        let idsToDelete = offset.map { index in
            section.budgets[index].id
        }
        
        budgets.removeAll { budget in
            idsToDelete.contains(budget.id)
        }
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
    BudgetListScreen()
}
