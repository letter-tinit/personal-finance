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
    case duplicatePeriod
}

struct Budget: Identifiable, Hashable, Codable {
    let id: UUID
    private(set) var periodStart: Date
    private(set) var income: Decimal
    private(set) var method: BudgetMethod
    let createdAt: Date
    private(set) var allocations: [BudgetAllocation]
    private(set) var fixedExpensePlans: [FixedExpensePlan]
    private(set) var transactions: [BudgetTransaction]

    init(
        id: UUID = UUID(),
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
        self.periodStart = periodStart
        self.income = income
        self.method = method
        self.createdAt = createdAt
        self.allocations = allocations
        self.fixedExpensePlans = fixedExpensePlans
        self.transactions = transactions
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

extension BudgetAllocation {
    var expectedTransactionType: TransactionType {
        kind.isSavingsLike ? .income : .expense
    }
}

enum FixedExpensePlanAmountType: String, CaseIterable, Hashable, Codable {
    case fixed
    case estimated
}

struct FixedExpensePlan: Identifiable, Hashable, Codable {
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

struct BudgetTransaction: Identifiable, Hashable, Codable {
    let id: UUID
    let budgetID: UUID
    let allocationID: UUID
    let type: TransactionType
    private(set) var title: String
    private(set) var note: String
    private(set) var occurredAt: Date
    private(set) var amount: Decimal
    private(set) var paymentMethod: PaymentMethod

    init(
        id: UUID = UUID(),
        budgetID: UUID,
        allocationID: UUID,
        type: TransactionType = .expense,
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

enum TransactionType: String, CaseIterable, Hashable, Codable {
    case expense
    case income
    
    var icon: String {
        switch self {
        case .expense:
            "arrow.down"
        case .income:
            "arrow.up"
        }
    }
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
    var name: String {
        Calendar.current.startOfMonth(for: periodStart).toString(withFormat: .month).capitalizingFirstLetter
    }
    
    static func make(
        periodStart: Date,
        income: Decimal,
        method: BudgetMethod,
        calendar: Calendar = .current
    ) -> Budget {
        let budgetID = UUID()
        let monthStart = calendar.startOfMonth(for: periodStart)
        let allocations = method.generateBucketByIncome(income).map { bucket in
            BudgetAllocation(
                budgetID: budgetID,
                kind: bucket.kind,
                ratio: bucket.ratio,
                targetAmount: bucket.amount
            )
        }

        return Budget(
            id: budgetID,
            periodStart: monthStart,
            income: income,
            method: method,
            allocations: allocations
        )
    }

    mutating func copyFixedExpensePlans(from sourceBudget: Budget) {
        guard let destinationAllocation = allocations.first(
            where: { $0.kind.supportsFixedExpensePlan }
        ) else {
            return
        }

        fixedExpensePlans = sourceBudget.fixedExpensePlans.map { plan in
            FixedExpensePlan(
                budgetID: id,
                allocationID: destinationAllocation.id,
                name: plan.name,
                amount: plan.amount,
                amountType: plan.amountType
            )
        }
    }

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
        type: TransactionType,
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
