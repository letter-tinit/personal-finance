//
//  Budget.swift
//  Personal Finance
//
//  Created by TiniT on 13/7/26.
//

import Foundation

enum BudgetError: Error {
    case invalidAmount
    case allocationNotFound
    case allocationBelongsToAnotherBudget
}

struct Budget: Identifiable, Hashable {
    let id: UUID
    private(set) var name: String
    private(set) var periodStart: Date
    private(set) var income: Decimal
    private(set) var method: BudgetMethod
    let createdAt: Date
    private(set) var allocations: [BudgetAllocation]
    private(set) var transactions: [BudgetTransaction]

    init(
        id: UUID = UUID(),
        name: String,
        periodStart: Date,
        income: Decimal,
        method: BudgetMethod,
        createdAt: Date = .now,
        allocations: [BudgetAllocation] = [],
        transactions: [BudgetTransaction] = []
    ) {
        let allocationIDs = Set(allocations.map(\.id))

        precondition(
            allocations.allSatisfy { $0.budgetID == id },
            "Every allocation must belong to this budget."
        )
        precondition(
            transactions.allSatisfy {
                $0.budgetID == id && allocationIDs.contains($0.allocationID)
            },
            "Every transaction must reference an allocation in this budget."
        )

        self.id = id
        self.name = name
        self.periodStart = periodStart
        self.income = income
        self.method = method
        self.createdAt = createdAt
        self.allocations = allocations
        self.transactions = transactions
    }
}

struct BudgetAllocation: Identifiable, Hashable {
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

struct BudgetTransaction: Identifiable, Hashable {
    let id: UUID
    let budgetID: UUID
    let allocationID: UUID
    let type: BudgetTransactionType
    private(set) var note: String
    private(set) var occurredAt: Date
    private(set) var amount: Decimal
    private(set) var paymentMethod: PaymentMethod

    init(
        id: UUID = UUID(),
        budgetID: UUID,
        allocationID: UUID,
        type: BudgetTransactionType = .expense,
        note: String,
        occurredAt: Date = .now,
        amount: Decimal,
        paymentMethod: PaymentMethod
    ) {
        self.id = id
        self.budgetID = budgetID
        self.allocationID = allocationID
        self.type = type
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

enum BudgetTransactionType: String, CaseIterable, Hashable {
    case expense
    case contribution
}

enum BudgetAllocationStatus: Hashable {
    // Savings
    case done
    case needMore

    // Standard
    case ok
    case over
}

struct BudgetAllocationSummary: Hashable {
    let allocation: BudgetAllocation
    let actualAmount: Decimal
    let remainingAmount: Decimal
    let status: BudgetAllocationStatus
    let barProgress: Decimal
    let displayBarProgress: Double
}

extension Budget {
    func transactions(for allocation: BudgetAllocation) -> [BudgetTransaction] {
        transactions.filter { $0.allocationID == allocation.id }
    }
    
    func allocation(
        for transaction: BudgetTransaction
    ) -> BudgetAllocation? {
        allocations.first {
            $0.id == transaction.allocationID
        }
    }
    
    func actualAmount(for allocation: BudgetAllocation) -> Decimal {
        transactions(for: allocation)
            .reduce(Decimal.zero) { partialResult, transaction in
                partialResult + transaction.amount
            }
    }
    
    func remainingAmount(for allocation: BudgetAllocation) -> Decimal {
        allocation.targetAmount - actualAmount(for: allocation)
    }
    
    func status(for allocation: BudgetAllocation) -> BudgetAllocationStatus {
        let actualAmount = actualAmount(for: allocation)
        let remainingAmount = allocation.targetAmount - actualAmount

        if allocation.kind.isSavingsLike {
            return actualAmount >= allocation.targetAmount ? .done : .needMore
        }

        return remainingAmount >= 0 ? .ok : .over
    }

    func barProgress(for allocation: BudgetAllocation) -> Decimal {
        guard allocation.targetAmount > 0 else {
            if allocation.kind.isSavingsLike {
                return actualAmount(for: allocation) > 0 ? 1 : .zero
            }

            return remainingAmount(for: allocation) > 0 ? 1 : .zero
        }

        if allocation.kind.isSavingsLike {
            return actualAmount(for: allocation) / allocation.targetAmount
        }

        return remainingAmount(for: allocation) / allocation.targetAmount
    }

    func allocationSummary(for allocation: BudgetAllocation) -> BudgetAllocationSummary {
        let actualAmount = actualAmount(for: allocation)
        let remainingAmount = allocation.targetAmount - actualAmount
        let barProgress = barProgress(for: allocation)

        return BudgetAllocationSummary(
            allocation: allocation,
            actualAmount: actualAmount,
            remainingAmount: remainingAmount,
            status: status(for: allocation),
            barProgress: barProgress,
            displayBarProgress: min(max(barProgress.doubleValue, 0), 1)
        )
    }

    mutating func addTransaction(
        allocationID: UUID,
        type: BudgetTransactionType,
        note: String,
        occurredAt: Date = .now,
        amount: Decimal,
        paymentMethod: PaymentMethod
    ) throws {
        guard amount > 0 else {
            throw BudgetError.invalidAmount
        }

        guard let allocation = allocations.first(
            where: { $0.id == allocationID }
        ) else {
            throw BudgetError.allocationNotFound
        }

        guard allocation.budgetID == id else {
            throw BudgetError.allocationBelongsToAnotherBudget
        }

        transactions.append(
            BudgetTransaction(
                budgetID: id,
                allocationID: allocation.id,
                type: type,
                note: note,
                occurredAt: occurredAt,
                amount: amount,
                paymentMethod: paymentMethod
            )
        )
    }
}

extension Budget {
    static let mock: Budget = {
        let budgetID = UUID()
        let calendar = Calendar(identifier: .gregorian)

        func date(day: Int) -> Date {
            calendar.date(from: DateComponents(year: 2026, month: 7, day: day))!
        }

        let needs = BudgetAllocation(
            budgetID: budgetID,
            kind: .needs,
            ratio: 0.5,
            targetAmount: 8_010_425
        )
        let wants = BudgetAllocation(
            budgetID: budgetID,
            kind: .wants,
            ratio: 0.3,
            targetAmount: 4_806_255
        )
        let savings = BudgetAllocation(
            budgetID: budgetID,
            kind: .savings,
            ratio: 0.2,
            targetAmount: 3_204_170
        )

        return Budget(
            id: budgetID,
            name: "July 2026",
            periodStart: date(day: 1),
            income: 16_020_850,
            method: .fiftyThirtyTwenty,
            allocations: [needs, wants, savings],
            transactions: [
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: needs.id,
                    note: "Electricity - HTX",
                    occurredAt: date(day: 5),
                    amount: 540_837,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: needs.id,
                    note: "Electricity - Binh Duong",
                    occurredAt: date(day: 6),
                    amount: 401_942,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: needs.id,
                    note: "Electricity - Street Lights",
                    occurredAt: date(day: 6),
                    amount: 235_600,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: needs.id,
                    note: "Electricity - Nguyen Quoc Hung",
                    occurredAt: date(day: 6),
                    amount: 441_461,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: needs.id,
                    note: "Electricity - Tran Bach Tuyet",
                    occurredAt: date(day: 6),
                    amount: 325_793,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: needs.id,
                    note: "Rent",
                    occurredAt: date(day: 6),
                    amount: 3_213_000,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: needs.id,
                    note: "iOS Team Fund",
                    occurredAt: date(day: 6),
                    amount: 100_000,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: needs.id,
                    note: "Living expenses",
                    occurredAt: date(day: 7),
                    amount: 700_000,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: wants.id,
                    note: "Give Family",
                    occurredAt: date(day: 7),
                    amount: 700_000,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: savings.id,
                    type: .contribution,
                    note: "Deposit Savings",
                    occurredAt: date(day: 10),
                    amount: 3_204_170,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: needs.id,
                    note: "Youtube Premium",
                    occurredAt: date(day: 12),
                    amount: 195_000,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: wants.id,
                    note: "Give Family",
                    occurredAt: date(day: 12),
                    amount: 155_200,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: needs.id,
                    note: "Metro",
                    occurredAt: date(day: 13),
                    amount: 300_000,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: needs.id,
                    note: "Living expenses",
                    occurredAt: date(day: 13),
                    amount: 300_000,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: needs.id,
                    note: "Living expenses",
                    occurredAt: date(day: 13),
                    amount: 500_000,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: wants.id,
                    note: "Bình trà",
                    occurredAt: date(day: 13),
                    amount: 95_000,
                    paymentMethod: .banking
                )
            ]
        )
    }()
}
