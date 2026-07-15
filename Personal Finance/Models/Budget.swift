//
//  Budget.swift
//  Personal Finance
//
//  Created by TiniT on 13/7/26.
//

import Foundation

enum BudgetError: Error {
    case invalidAmount
    case invalidTransactionType
    case allocationNotFound
    case allocationBelongsToAnotherBudget
    case transactionNotFound
    case fixedExpensePlanNotFound
    case fixedExpensePlanAlreadyCompleted
    case invalidFixedExpensePlanAmount
    case unsupportedFixedExpensePlanAllocation
}

struct Budget: Identifiable, Hashable {
    let id: UUID
    private(set) var name: String
    private(set) var periodStart: Date
    private(set) var income: Decimal
    private(set) var method: BudgetMethod
    let createdAt: Date
    private(set) var allocations: [BudgetAllocation]
    private(set) var fixedExpensePlans: [FixedExpensePlan]
    private(set) var transactions: [BudgetTransaction]

    init(
        id: UUID = UUID(),
        name: String,
        periodStart: Date,
        income: Decimal,
        method: BudgetMethod,
        createdAt: Date = .now,
        allocations: [BudgetAllocation] = [],
        fixedExpensePlans: [FixedExpensePlan] = [],
        transactions: [BudgetTransaction] = []
    ) {
        let allocationIDs = Set(allocations.map(\.id))
        let allocationsByID = Dictionary(
            uniqueKeysWithValues: allocations.map { ($0.id, $0) }
        )
        let transactionsByID = Dictionary(
            uniqueKeysWithValues: transactions.map { ($0.id, $0) }
        )

        precondition(
            allocations.allSatisfy { $0.budgetID == id },
            "Every allocation must belong to this budget."
        )
        precondition(
            fixedExpensePlans.allSatisfy {
                $0.budgetID == id && allocationIDs.contains($0.allocationID)
            },
            "Every fixed expense plan must reference an allocation in this budget."
        )
        precondition(
            fixedExpensePlans.allSatisfy {
                allocationsByID[$0.allocationID]?.kind.supportsFixedExpensePlan == true
            },
            "Fixed expense plans are only supported by essential allocations."
        )
        precondition(
            transactions.allSatisfy {
                $0.budgetID == id && allocationIDs.contains($0.allocationID)
            },
            "Every transaction must reference an allocation in this budget."
        )
        precondition(
            transactions.allSatisfy {
                allocationsByID[$0.allocationID]?.expectedTransactionType == $0.type
            },
            "Every transaction type must match its allocation."
        )
        precondition(
            fixedExpensePlans.allSatisfy { plan in
                guard let transactionID = plan.transactionID,
                      let transaction = transactionsByID[transactionID] else {
                    return plan.transactionID == nil
                }

                return transaction.budgetID == id
                    && transaction.allocationID == plan.allocationID
            },
            "Every completed fixed expense plan must reference its transaction."
        )

        self.id = id
        self.name = name
        self.periodStart = periodStart
        self.income = income
        self.method = method
        self.createdAt = createdAt
        self.allocations = allocations
        self.fixedExpensePlans = fixedExpensePlans
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

extension BudgetAllocation {
    var expectedTransactionType: BudgetTransactionType {
        kind.isSavingsLike ? .contribution : .expense
    }
}

enum FixedExpensePlanAmountType: String, CaseIterable, Hashable, Codable {
    case fixed
    case estimated
}

struct FixedExpensePlan: Identifiable, Hashable {
    let id: UUID
    let budgetID: UUID
    let allocationID: UUID
    private(set) var name: String
    private(set) var amount: Decimal
    private(set) var amountType: FixedExpensePlanAmountType
    private(set) var transactionID: UUID?

    init(
        id: UUID = UUID(),
        budgetID: UUID,
        allocationID: UUID,
        name: String,
        amount: Decimal,
        amountType: FixedExpensePlanAmountType = .estimated,
        transactionID: UUID? = nil
    ) {
        self.id = id
        self.budgetID = budgetID
        self.allocationID = allocationID
        self.name = name
        self.amount = amount
        self.amountType = amountType
        self.transactionID = transactionID
    }
}

extension FixedExpensePlan {
    static func mocks(
        budgetID: UUID,
        allocationID: UUID
    ) -> [FixedExpensePlan] {
        [
            FixedExpensePlan(
                budgetID: budgetID,
                allocationID: allocationID,
                name: "Rent",
                amount: 3_213_000,
                amountType: .fixed
            ),
            FixedExpensePlan(
                budgetID: budgetID,
                allocationID: allocationID,
                name: "Codex Renewal",
                amount: .zero,
                amountType: .fixed
            ),
            FixedExpensePlan(
                budgetID: budgetID,
                allocationID: allocationID,
                name: "YouTube Premium",
                amount: 195_000,
                amountType: .fixed
            ),
            FixedExpensePlan(
                budgetID: budgetID,
                allocationID: allocationID,
                name: "Electricity - Binh Duong",
                amount: 401_942
            ),
            FixedExpensePlan(
                budgetID: budgetID,
                allocationID: allocationID,
                name: "Electricity - HTX",
                amount: 540_837
            ),
            FixedExpensePlan(
                budgetID: budgetID,
                allocationID: allocationID,
                name: "Electricity - Street Lights",
                amount: 235_600
            ),
            FixedExpensePlan(
                budgetID: budgetID,
                allocationID: allocationID,
                name: "Electricity - Nguyen Quoc Hung",
                amount: 441_461
            ),
            FixedExpensePlan(
                budgetID: budgetID,
                allocationID: allocationID,
                name: "Electricity - Tran Bach Tuyet",
                amount: 325_793
            ),
            FixedExpensePlan(
                budgetID: budgetID,
                allocationID: allocationID,
                name: "Internet - Binh Duong",
                amount: .zero
            ),
            FixedExpensePlan(
                budgetID: budgetID,
                allocationID: allocationID,
                name: "iOS Team Fund",
                amount: 100_000,
                amountType: .fixed
            ),
            FixedExpensePlan(
                budgetID: budgetID,
                allocationID: allocationID,
                name: "Metro",
                amount: 300_000
            ),
            FixedExpensePlan(
                budgetID: budgetID,
                allocationID: allocationID,
                name: "Living expenses",
                amount: 1_000_000
            )
        ]
    }
}

struct BudgetTransaction: Identifiable, Hashable {
    let id: UUID
    let budgetID: UUID
    let allocationID: UUID
    let type: BudgetTransactionType
    private(set) var title: String
    private(set) var note: String
    private(set) var occurredAt: Date
    private(set) var amount: Decimal
    private(set) var paymentMethod: PaymentMethod

    init(
        id: UUID = UUID(),
        budgetID: UUID,
        allocationID: UUID,
        type: BudgetTransactionType = .expense,
        title: String,
        note: String = "",
        occurredAt: Date = .now,
        amount: Decimal,
        paymentMethod: PaymentMethod
    ) {
        self.id = id
        self.budgetID = budgetID
        self.allocationID = allocationID
        self.type = type
        self.title = title
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
    let planRatio: Decimal
    let actualRatio: Decimal
    let barProgress: Decimal
    let displayBarProgress: Double
}

extension Budget {
    func transactions(for allocation: BudgetAllocation) -> [BudgetTransaction] {
        transactions.filter { $0.allocationID == allocation.id }
    }

    func fixedExpensePlans(for allocation: BudgetAllocation) -> [FixedExpensePlan] {
        guard allocation.kind.supportsFixedExpensePlan else {
            return []
        }

        return fixedExpensePlans.filter { $0.allocationID == allocation.id }
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

    func actualRatio(for allocation: BudgetAllocation) -> Decimal {
        guard income > 0 else {
            return .zero
        }

        return actualAmount(for: allocation) / income
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
            planRatio: allocation.ratio,
            actualRatio: actualRatio(for: allocation),
            barProgress: barProgress,
            displayBarProgress: min(max(barProgress.doubleValue, 0), 1)
        )
    }

    mutating func addTransaction(
        allocationID: UUID,
        type: BudgetTransactionType,
        title: String,
        note: String = "",
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

        guard type == allocation.expectedTransactionType else {
            throw BudgetError.invalidTransactionType
        }

        transactions.append(
            BudgetTransaction(
                budgetID: id,
                allocationID: allocation.id,
                type: type,
                title: title,
                note: note,
                occurredAt: occurredAt,
                amount: amount,
                paymentMethod: paymentMethod
            )
        )
    }

    mutating func updateTransaction(
        id transactionID: UUID,
        allocationID: UUID,
        title: String,
        note: String = "",
        occurredAt: Date,
        amount: Decimal,
        paymentMethod: PaymentMethod
    ) throws {
        guard amount > 0 else {
            throw BudgetError.invalidAmount
        }

        guard let transactionIndex = transactions.firstIndex(
            where: { $0.id == transactionID }
        ) else {
            throw BudgetError.transactionNotFound
        }

        guard let allocation = allocations.first(
            where: { $0.id == allocationID }
        ) else {
            throw BudgetError.allocationNotFound
        }

        guard allocation.budgetID == id else {
            throw BudgetError.allocationBelongsToAnotherBudget
        }

        transactions[transactionIndex] = BudgetTransaction(
            id: transactionID,
            budgetID: id,
            allocationID: allocation.id,
            type: allocation.expectedTransactionType,
            title: title,
            note: note,
            occurredAt: occurredAt,
            amount: amount,
            paymentMethod: paymentMethod
        )

        if let linkedPlanIndex = fixedExpensePlans.firstIndex(
            where: { $0.transactionID == transactionID }
        ), fixedExpensePlans[linkedPlanIndex].allocationID != allocationID {
            let linkedPlan = fixedExpensePlans[linkedPlanIndex]
            fixedExpensePlans[linkedPlanIndex] = FixedExpensePlan(
                id: linkedPlan.id,
                budgetID: linkedPlan.budgetID,
                allocationID: linkedPlan.allocationID,
                name: linkedPlan.name,
                amount: linkedPlan.amount,
                amountType: linkedPlan.amountType
            )
        }
    }

    mutating func deleteTransaction(id transactionID: UUID) throws {
        guard let transactionIndex = transactions.firstIndex(
            where: { $0.id == transactionID }
        ) else {
            throw BudgetError.transactionNotFound
        }

        transactions.remove(at: transactionIndex)

        if let linkedPlanIndex = fixedExpensePlans.firstIndex(
            where: { $0.transactionID == transactionID }
        ) {
            let linkedPlan = fixedExpensePlans[linkedPlanIndex]
            fixedExpensePlans[linkedPlanIndex] = FixedExpensePlan(
                id: linkedPlan.id,
                budgetID: linkedPlan.budgetID,
                allocationID: linkedPlan.allocationID,
                name: linkedPlan.name,
                amount: linkedPlan.amount,
                amountType: linkedPlan.amountType
            )
        }
    }

    mutating func addFixedExpensePlan(
        allocationID: UUID,
        name: String,
        amount: Decimal,
        amountType: FixedExpensePlanAmountType
    ) throws {
        let allocation = try fixedExpensePlanAllocation(id: allocationID)
        guard amount >= 0 else {
            throw BudgetError.invalidFixedExpensePlanAmount
        }

        fixedExpensePlans.append(
            FixedExpensePlan(
                budgetID: id,
                allocationID: allocation.id,
                name: name,
                amount: amount,
                amountType: amountType
            )
        )
    }

    mutating func updateFixedExpensePlan(
        id planID: UUID,
        name: String,
        amount: Decimal,
        amountType: FixedExpensePlanAmountType
    ) throws {
        guard let planIndex = fixedExpensePlans.firstIndex(
            where: { $0.id == planID }
        ) else {
            throw BudgetError.fixedExpensePlanNotFound
        }

        guard amount >= 0 else {
            throw BudgetError.invalidFixedExpensePlanAmount
        }

        let currentPlan = fixedExpensePlans[planIndex]
        _ = try fixedExpensePlanAllocation(id: currentPlan.allocationID)

        fixedExpensePlans[planIndex] = FixedExpensePlan(
            id: planID,
            budgetID: id,
            allocationID: currentPlan.allocationID,
            name: name,
            amount: amount,
            amountType: amountType,
            transactionID: currentPlan.transactionID
        )
    }

    mutating func completeFixedExpensePlan(
        id planID: UUID,
        title: String,
        note: String = "",
        occurredAt: Date,
        amount: Decimal,
        paymentMethod: PaymentMethod
    ) throws {
        guard amount > 0 else {
            throw BudgetError.invalidAmount
        }

        guard let planIndex = fixedExpensePlans.firstIndex(
            where: { $0.id == planID }
        ) else {
            throw BudgetError.fixedExpensePlanNotFound
        }

        let plan = fixedExpensePlans[planIndex]
        guard plan.transactionID == nil else {
            throw BudgetError.fixedExpensePlanAlreadyCompleted
        }

        let allocation = try fixedExpensePlanAllocation(id: plan.allocationID)
        let transactionID = UUID()

        transactions.append(
            BudgetTransaction(
                id: transactionID,
                budgetID: id,
                allocationID: allocation.id,
                type: allocation.expectedTransactionType,
                title: title,
                note: note,
                occurredAt: occurredAt,
                amount: amount,
                paymentMethod: paymentMethod
            )
        )

        fixedExpensePlans[planIndex] = FixedExpensePlan(
            id: plan.id,
            budgetID: plan.budgetID,
            allocationID: plan.allocationID,
            name: plan.name,
            amount: plan.amount,
            amountType: plan.amountType,
            transactionID: transactionID
        )
    }

    mutating func deleteFixedExpensePlan(id planID: UUID) throws {
        guard let planIndex = fixedExpensePlans.firstIndex(
            where: { $0.id == planID }
        ) else {
            throw BudgetError.fixedExpensePlanNotFound
        }

        fixedExpensePlans.remove(at: planIndex)
    }

    private func fixedExpensePlanAllocation(
        id allocationID: UUID
    ) throws -> BudgetAllocation {
        guard let allocation = allocations.first(
            where: { $0.id == allocationID }
        ) else {
            throw BudgetError.allocationNotFound
        }

        guard allocation.budgetID == id else {
            throw BudgetError.allocationBelongsToAnotherBudget
        }

        guard allocation.kind.supportsFixedExpensePlan else {
            throw BudgetError.unsupportedFixedExpensePlanAllocation
        }

        return allocation
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
            fixedExpensePlans: FixedExpensePlan.mocks(
                budgetID: budgetID,
                allocationID: needs.id
            ),
            transactions: [
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: needs.id,
                    title: "Electricity - HTX",
                    occurredAt: date(day: 5),
                    amount: 540_837,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: needs.id,
                    title: "Electricity - Binh Duong",
                    occurredAt: date(day: 6),
                    amount: 401_942,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: needs.id,
                    title: "Electricity - Street Lights",
                    occurredAt: date(day: 6),
                    amount: 235_600,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: needs.id,
                    title: "Electricity - Nguyen Quoc Hung",
                    occurredAt: date(day: 6),
                    amount: 441_461,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: needs.id,
                    title: "Electricity - Tran Bach Tuyet",
                    occurredAt: date(day: 6),
                    amount: 325_793,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: needs.id,
                    title: "Rent",
                    occurredAt: date(day: 6),
                    amount: 3_213_000,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: needs.id,
                    title: "iOS Team Fund",
                    occurredAt: date(day: 6),
                    amount: 100_000,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: needs.id,
                    title: "Living expenses",
                    occurredAt: date(day: 7),
                    amount: 700_000,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: wants.id,
                    title: "Give Family",
                    occurredAt: date(day: 7),
                    amount: 700_000,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: savings.id,
                    type: .contribution,
                    title: "Deposit Savings",
                    occurredAt: date(day: 10),
                    amount: 3_204_170,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: needs.id,
                    title: "Youtube Premium",
                    occurredAt: date(day: 12),
                    amount: 195_000,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: wants.id,
                    title: "Give Family",
                    occurredAt: date(day: 12),
                    amount: 155_200,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: needs.id,
                    title: "Metro",
                    occurredAt: date(day: 13),
                    amount: 300_000,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: needs.id,
                    title: "Living expenses",
                    occurredAt: date(day: 13),
                    amount: 300_000,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: needs.id,
                    title: "Living expenses",
                    occurredAt: date(day: 13),
                    amount: 500_000,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: wants.id,
                    title: "Bình trà",
                    occurredAt: date(day: 13),
                    amount: 95_000,
                    paymentMethod: .banking
                )
            ]
        )
    }()

    static let sixJarsMock: Budget = {
        let budgetID = UUID()
        let calendar = Calendar(identifier: .gregorian)

        func date(day: Int) -> Date {
            calendar.date(
                from: DateComponents(year: 2026, month: 7, day: day)
            )!
        }

        let necessities = BudgetAllocation(
            budgetID: budgetID,
            kind: .necessities,
            ratio: 0.55,
            targetAmount: 8_811_468
        )
        let financialFreedom = BudgetAllocation(
            budgetID: budgetID,
            kind: .financialFreedom,
            ratio: 0.10,
            targetAmount: 1_602_085
        )
        let education = BudgetAllocation(
            budgetID: budgetID,
            kind: .education,
            ratio: 0.10,
            targetAmount: 1_602_085
        )
        let longTermSavings = BudgetAllocation(
            budgetID: budgetID,
            kind: .longTermSavings,
            ratio: 0.10,
            targetAmount: 1_602_085
        )
        let play = BudgetAllocation(
            budgetID: budgetID,
            kind: .play,
            ratio: 0.10,
            targetAmount: 1_602_085
        )
        let give = BudgetAllocation(
            budgetID: budgetID,
            kind: .give,
            ratio: 0.05,
            targetAmount: 801_042
        )

        return Budget(
            id: budgetID,
            name: "July 2026 - 6 Jars",
            periodStart: date(day: 1),
            income: 16_020_850,
            method: .sixJars,
            allocations: [
                necessities,
                financialFreedom,
                education,
                longTermSavings,
                play,
                give
            ],
            fixedExpensePlans: FixedExpensePlan.mocks(
                budgetID: budgetID,
                allocationID: necessities.id
            ),
            transactions: [
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: necessities.id,
                    title: "Rent",
                    occurredAt: date(day: 5),
                    amount: 3_213_000,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: necessities.id,
                    title: "Utilities",
                    occurredAt: date(day: 6),
                    amount: 1_000_000,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: financialFreedom.id,
                    type: .contribution,
                    title: "Investment account",
                    occurredAt: date(day: 7),
                    amount: 1_000_000,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: education.id,
                    title: "Online course",
                    occurredAt: date(day: 8),
                    amount: 500_000,
                    paymentMethod: .card
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: longTermSavings.id,
                    type: .contribution,
                    title: "Long-term deposit",
                    note: "Over-target example",
                    occurredAt: date(day: 9),
                    amount: 1_800_000,
                    paymentMethod: .banking
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: play.id,
                    title: "Weekend activity",
                    occurredAt: date(day: 10),
                    amount: 400_000,
                    paymentMethod: .card
                ),
                BudgetTransaction(
                    budgetID: budgetID,
                    allocationID: give.id,
                    title: "Family gift",
                    occurredAt: date(day: 11),
                    amount: 200_000,
                    paymentMethod: .cash
                )
            ]
        )
    }()
}
