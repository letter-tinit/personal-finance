//
//  BudgetViewModel.swift
//  Personal Finance
//
//  Created by TiniT on 22/7/26.
//

import Foundation

@Observable
final class BudgetViewModel {
    private let repository: BudgetRepository
    var budgets: [Budget] = []
    var errorMessage: String?

    init(repository: BudgetRepository) {
        self.repository = repository
        load()
    }

    func load() {
        do {
            budgets = try repository.fetchBudgets()
        } catch {
            errorMessage = "budget.storage.error.load".localized
        }
    }

    func createBudget(_ budget: Budget) {
        do {
            try repository.addBudget(budget)
            budgets.append(budget)
        } catch {
            errorMessage = "budget.create.error.save".localized
        }
    }

    func deleteBudget(_ budget: Budget) {
        do {
            try repository.removeBudget(budget)
            budgets.removeAll { $0.id == budget.id }
        } catch {
            errorMessage = "budget.storage.error.save".localized
        }
    }

    func save() {
        do { try repository.save() } catch { errorMessage = "budget.storage.error.save".localized }
    }
}
