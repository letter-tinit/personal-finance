//
//  Budget.swift
//  Personal Finance
//
//  Created by TiniT on 13/7/26.
//
import Foundation
import SwiftData

enum BudgetError: LocalizedError {
    case invalidAmount
    case invalidTransactionType
    case allocationNotFound
    case transactionNotFound
    case fixedExpensePlanNotFound
    case fixedExpensePlanAlreadyCompleted
    case invalidFixedExpensePlanAmount
    case unsupportedFixedExpensePlanAllocation
    case duplicatePeriod

    var errorDescription: String? {
        switch self {
        case .invalidAmount: "transaction.form.error.amount.positive".localized
        case .invalidTransactionType: "transaction.form.error.description".localized
        case .allocationNotFound: "transaction.form.error.allocation".localized
        case .transactionNotFound: "transaction.form.error.delete".localized
        case .fixedExpensePlanNotFound: "fixed.plan.form.error.delete".localized
        case .fixedExpensePlanAlreadyCompleted: "fixed.plan.form.error.save".localized
        case .invalidFixedExpensePlanAmount: "fixed.plan.form.error.amount".localized
        case .unsupportedFixedExpensePlanAllocation: "fixed.plan.form.error.save".localized
        case .duplicatePeriod: "budget.create.error.duplicatePeriod".localized
        }
    }
}

@Model
final class Budget: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var periodStart: Date = Date()
    var income: Decimal = 0
    var method: BudgetMethod = BudgetMethod.fiftyThirtyTwenty
    var createdAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \BudgetAllocation.budget)
    var allocations: [BudgetAllocation] = []

    @Relationship(deleteRule: .cascade, inverse: \FixedExpensePlan.budget)
    var fixedExpensePlans: [FixedExpensePlan] = []

    @Relationship(deleteRule: .cascade, inverse: \BudgetTransaction.budget)
    var transactions: [BudgetTransaction] = []

    init(id: UUID = UUID(), periodStart: Date, income: Decimal, method: BudgetMethod, createdAt: Date = .now) {
        self.id = id
        self.periodStart = periodStart
        self.income = income
        self.method = method
        self.createdAt = createdAt
    }
}

extension Budget: Hashable {
    static func == (lhs: Budget, rhs: Budget) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

@Model
final class BudgetAllocation: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var budget: Budget?
    var kind: BudgetBucketKind = BudgetBucketKind.needs
    var ratio: Decimal = 0
    var targetAmount: Decimal = 0

    @Relationship(deleteRule: .cascade, inverse: \BudgetTransaction.allocation)
    var transactions: [BudgetTransaction] = []

    @Relationship(deleteRule: .cascade, inverse: \FixedExpensePlan.allocation)
    var fixedExpensePlans: [FixedExpensePlan] = []

    init(id: UUID = UUID(), budget: Budget? = nil, kind: BudgetBucketKind, ratio: Decimal, targetAmount: Decimal) {
        self.id = id
        self.budget = budget
        self.kind = kind
        self.ratio = ratio
        self.targetAmount = targetAmount
    }
}

extension BudgetAllocation: Hashable {
    static func == (lhs: BudgetAllocation, rhs: BudgetAllocation) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

extension BudgetAllocation {
    var expectedTransactionType: TransactionType {
        kind.isSavingsLike ? .income : .expense
    }
}

enum FixedExpensePlanAmountType: String, CaseIterable, Codable {
    case fixed
    case estimated
}

@Model
final class FixedExpensePlan: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var budget: Budget?
    var allocation: BudgetAllocation?
    var name: String = ""
    var amount: Decimal = 0
    var amountType: FixedExpensePlanAmountType = FixedExpensePlanAmountType.estimated

    @Relationship(deleteRule: .nullify, inverse: \BudgetTransaction.fixedExpensePlan)
    var transaction: BudgetTransaction?

    init(id: UUID = UUID(), budget: Budget? = nil, allocation: BudgetAllocation? = nil, name: String, amount: Decimal, amountType: FixedExpensePlanAmountType = .estimated) {
        self.id = id
        self.budget = budget
        self.allocation = allocation
        self.name = name
        self.amount = amount
        self.amountType = amountType
    }
}

extension FixedExpensePlan: Hashable {
    static func == (lhs: FixedExpensePlan, rhs: FixedExpensePlan) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

@Model
final class BudgetTransaction: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var budget: Budget?
    var allocation: BudgetAllocation?
    var type: TransactionType = TransactionType.expense
    var title: String = ""
    var note: String = ""
    var occurredAt: Date = Date()
    var amount: Decimal = 0
    var paymentMethod: PaymentMethod = PaymentMethod.banking

    // inverse được suy ra từ FixedExpensePlan.transaction — KHÔNG khai báo @Relationship ở đây
    var fixedExpensePlan: FixedExpensePlan?

    init(id: UUID = UUID(), budget: Budget? = nil, allocation: BudgetAllocation? = nil, type: TransactionType = .expense, title: String, note: String = "", occurredAt: Date = .now, amount: Decimal, paymentMethod: PaymentMethod) {
        self.id = id
        self.budget = budget
        self.allocation = allocation
        self.type = type
        self.title = title
        self.note = note
        self.occurredAt = occurredAt
        self.amount = amount
        self.paymentMethod = paymentMethod
    }
}

extension BudgetTransaction: Hashable {
    static func == (lhs: BudgetTransaction, rhs: BudgetTransaction) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum PaymentMethod: String, CaseIterable, Codable {
    case banking, cash, card
}

enum TransactionType: String, CaseIterable, Codable {
    case expense, income
    var icon: String { self == .expense ? "arrow.down" : "arrow.up" }
    var titleKey: String { "transaction.type.\(rawValue)" }
    var localizedTitle: String { titleKey.localized }
}

enum BudgetAllocationStatus: Hashable {
    case done, needMore, ok, over
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

    static func make(periodStart: Date, income: Decimal, method: BudgetMethod, calendar: Calendar = .current) -> Budget {
        let monthStart = calendar.startOfMonth(for: periodStart)
        let budget = Budget(periodStart: monthStart, income: income, method: method)

        for bucket in method.generateBucketByIncome(income) {
            let allocation = BudgetAllocation(budget: budget, kind: bucket.kind, ratio: bucket.ratio, targetAmount: bucket.amount)
            budget.allocations.append(allocation)
        }
        return budget
    }

    func copyFixedExpensePlans(from sourceBudget: Budget) {
        guard let destination = allocations.first(where: { $0.kind.supportsFixedExpensePlan }) else { return }
        for plan in sourceBudget.fixedExpensePlans {
            let newPlan = FixedExpensePlan(budget: self, allocation: destination, name: plan.name, amount: plan.amount, amountType: plan.amountType)
            fixedExpensePlans.append(newPlan)
        }
    }

    func actualAmount(for allocation: BudgetAllocation) -> Decimal {
        allocation.transactions.reduce(Decimal.zero) { $0 + $1.amount }
    }

    func allocation(for transaction: BudgetTransaction) -> BudgetAllocation? {
        allocations.first { $0.id == transaction.allocation?.id }
    }

    func transactions(for allocation: BudgetAllocation) -> [BudgetTransaction] {
        allocation.transactions
    }

    func fixedExpensePlans(for allocation: BudgetAllocation) -> [FixedExpensePlan] {
        guard allocation.kind.supportsFixedExpensePlan else { return [] }
        return allocation.fixedExpensePlans
    }

    func status(for allocation: BudgetAllocation) -> BudgetAllocationStatus {
        let actualAmount = actualAmount(for: allocation)
        let remainingAmount = allocation.targetAmount - actualAmount

        if allocation.kind.isSavingsLike {
            return actualAmount >= allocation.targetAmount ? .done : .needMore
        }

        return remainingAmount >= 0 ? .ok : .over
    }

    func remainingAmount(for allocation: BudgetAllocation) -> Decimal {
        allocation.targetAmount - actualAmount(for: allocation)
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
        guard income > 0 else { return .zero }
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
}
