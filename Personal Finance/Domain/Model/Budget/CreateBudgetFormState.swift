//
//  CreateBudgetFormState.swift
//  Personal Finance
//
//  Created by TiniT on 15/7/26.
//

import Foundation

enum CreateBudgetFormValidationError: Error, Equatable {
    case invalidIncome
    case duplicatePeriod
}

struct ValidatedBudgetInput: Equatable {
    let periodStart: Date
    let income: Decimal
    let method: BudgetMethod
    let reusesFixedExpensePlans: Bool
}

struct CreateBudgetFormState: Equatable {
    var periodStart: Date
    var incomeText: String
    var method: BudgetMethod
    var reusesFixedExpensePlans: Bool

    init(
        templateBudget: Budget?,
        calendar: Calendar = .current,
        today: Date = .now
    ) {
        if let templateBudget {
            periodStart = calendar.nextMonth(after: templateBudget.periodStart)
            incomeText = templateBudget.income.toAmountString
            method = templateBudget.method
            reusesFixedExpensePlans = !templateBudget.fixedExpensePlans.isEmpty
        } else {
            periodStart = calendar.startOfMonth(for: today)
            incomeText = ""
            method = .fiftyThirtyTwenty
            reusesFixedExpensePlans = false
        }
    }

    func validatedInput(
        existingBudgets: [Budget],
        calendar: Calendar = .current
    ) throws -> ValidatedBudgetInput {
        let normalizedAmount = incomeText
            .filter(\.isNumber)

        guard let income = Decimal(string: normalizedAmount), income > 0 else {
            throw CreateBudgetFormValidationError.invalidIncome
        }

        let monthStart = calendar.startOfMonth(for: periodStart)
        guard !existingBudgets.contains(where: {
            calendar.isDate($0.periodStart, equalTo: monthStart, toGranularity: .month)
        }) else {
            throw CreateBudgetFormValidationError.duplicatePeriod
        }

        return ValidatedBudgetInput(
            periodStart: monthStart,
            income: income,
            method: method,
            reusesFixedExpensePlans: reusesFixedExpensePlans
        )
    }
}

extension CreateBudgetFormValidationError {
    var localizationKey: String {
        switch self {
        case .invalidIncome:
            "budget.create.error.income"
        case .duplicatePeriod:
            "budget.create.error.duplicatePeriod"
        }
    }
}
