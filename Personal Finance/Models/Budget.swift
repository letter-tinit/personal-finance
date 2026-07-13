//
//  Budget.swift
//  Personal Finance
//
//  Created by TiniT on 13/7/26.
//

import Foundation

struct Budget: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var periodStart: Date
    var income: Decimal
    var method: BudgetMethod
    let createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        periodStart: Date,
        income: Decimal,
        method: BudgetMethod,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.periodStart = periodStart
        self.income = income
        self.method = method
        self.createdAt = createdAt
    }
}

struct BudgetAllocation: Identifiable, Hashable, Codable {
    let id: UUID
    let budgetID: UUID
    let kind: BudgetBucketKind
    let ratio: Decimal
    let targetAmount: Decimal

    init(
        id: UUID = UUID(),
        budgetID: UUID,
        kind: BudgetBucketKind,
        ratio: Decimal,
        targetAmount: Decimal
    ) {
        self.id = id
        self.budgetID = budgetID
        self.kind = kind
        self.ratio = ratio
        self.targetAmount = targetAmount
    }
}

struct BudgetTransaction: Identifiable, Hashable, Codable {
    let id: UUID
    let budgetID: UUID
    let allocationID: UUID
    var note: String
    var occurredAt: Date
    var amount: Decimal
    var paymentMethod: PaymentMethod

    init(
        id: UUID = UUID(),
        budgetID: UUID,
        allocationID: UUID,
        note: String,
        occurredAt: Date = .now,
        amount: Decimal,
        paymentMethod: PaymentMethod
    ) {
        self.id = id
        self.budgetID = budgetID
        self.allocationID = allocationID
        self.note = note
        self.occurredAt = occurredAt
        self.amount = amount
        self.paymentMethod = paymentMethod
    }
}

enum PaymentMethod: String, CaseIterable, Hashable, Codable {
    case banking
    case cash
    case card
}

struct BudgetDetails: Hashable {
    let budget: Budget
    var allocations: [BudgetAllocation]
    var transactions: [BudgetTransaction]
}

extension BudgetDetails {
    static let mock: BudgetDetails = {
        let budget = Budget(
            name: "July 2026",
            periodStart: Date(timeIntervalSince1970: 1_782_838_800),
            income: 20_000_000,
            method: .fiftyThirtyTwenty
        )

        let needs = BudgetAllocation(
            budgetID: budget.id,
            kind: .needs,
            ratio: 0.5,
            targetAmount: 10_000_000
        )
        let wants = BudgetAllocation(
            budgetID: budget.id,
            kind: .wants,
            ratio: 0.3,
            targetAmount: 6_000_000
        )
        let savings = BudgetAllocation(
            budgetID: budget.id,
            kind: .savings,
            ratio: 0.2,
            targetAmount: 4_000_000
        )

        return BudgetDetails(
            budget: budget,
            allocations: [needs, wants, savings],
            transactions: [
                BudgetTransaction(
                    budgetID: budget.id,
                    allocationID: needs.id,
                    note: "Apartment rent",
                    amount: 5_000_000,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budget.id,
                    allocationID: needs.id,
                    note: "Groceries",
                    amount: 1_200_000,
                    paymentMethod: .card
                ),
                BudgetTransaction(
                    budgetID: budget.id,
                    allocationID: wants.id,
                    note: "Coffee with friends",
                    amount: 150_000,
                    paymentMethod: .cash
                ),
                BudgetTransaction(
                    budgetID: budget.id,
                    allocationID: savings.id,
                    note: "Emergency fund",
                    amount: 2_000_000,
                    paymentMethod: .banking
                )
            ]
        )
    }()
}
