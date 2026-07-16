//
//  Balance.swift
//  Personal Finance
//
//  Created by TiniT on 16/7/26.
//

import Foundation

struct Balance {
    let transactions: [BalanceTransaction]
}

struct BalanceTransaction: Hashable {
    let note: String
    let transactionType: TransactionType
    let occurredAt: Date
    let amount: Decimal
    let balanceSnapshot: Decimal
    let paymentMethod: PaymentMethod
}

enum BalanceStatus {
    case positive
    case negative
    case balanced
}

extension Balance {
    var inflow: Decimal {
        transactions
            .filter{ $0.transactionType == .income }
            .reduce(Decimal.zero) { partialResult, transaction in
                partialResult + transaction.amount
            }
    }
    
    var outflow: Decimal {
        transactions
            .filter{ $0.transactionType == .expense }
            .reduce(Decimal.zero) { partialResult, transaction in
                partialResult + transaction.amount
            }
    }
    
    var status: BalanceStatus {
        if inflow > outflow {
            return .positive
        } else if inflow < outflow {
            return .negative
        } else {
            return .balanced
        }
    }
    
    
    var symbol: String {
        switch status {
        case .positive:
            return "arrow.up.circle.fill"
            
        case .negative:
            return "arrow.down.circle.fill"
            
        case .balanced:
            return "equal.circle.fill"
        }
    }
    
    var name: String {
        switch status {
        case .positive:
            return "balance.status.positive"
            
        case .negative:
            return "balance.status.negative"
            
        case .balanced:
            return "balance.status.balanced"
        }
    }
    
    var sign: String {
        switch status {
        case .positive:
            "+"
        case .negative:
            "-"
        case .balanced:
            ""
        }
    }
    
    var displayBalance: String {
        sign + " " + balance.formattedVND
    }
    
    var balance: Decimal {
        abs((inflow - outflow))
    }
}

extension Balance {
    static let mock = Balance(
        transactions: [
            .test,
            .mockSalary,
            .mockFreelance,
            .mockCoffee,
            .mockLunch,
            .mockNetflix,
            .mockGroceries
        ]
    )
}

extension BalanceTransaction {
    static let test = BalanceTransaction(
        note: "test",
        transactionType: .expense,
        occurredAt: Calendar.current.date(byAdding: .day, value: -20, to: Date())!,
        amount: 1_850_000,
        balanceSnapshot: 15_000_000,
        paymentMethod: .banking
    )
    
    static let mockSalary = BalanceTransaction(
        note: "Monthly Salary",
        transactionType: .income,
        occurredAt: Calendar.current.date(byAdding: .day, value: -20, to: Date())!,
        amount: 15_000_000,
        balanceSnapshot: 15_000_000,
        paymentMethod: .banking
    )

    static let mockFreelance = BalanceTransaction(
        note: "Freelance Project",
        transactionType: .income,
        occurredAt: Calendar.current.date(byAdding: .day, value: -15, to: Date())!,
        amount: 2_000_000,
        balanceSnapshot: 17_000_000,
        paymentMethod: .banking
    )

    static let mockCoffee = BalanceTransaction(
        note: "Coffee",
        transactionType: .expense,
        occurredAt: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
        amount: 65_000,
        balanceSnapshot: 16_935_000,
        paymentMethod: .banking
    )

    static let mockLunch = BalanceTransaction(
        note: "Lunch",
        transactionType: .expense,
        occurredAt: Calendar.current.date(byAdding: .day, value: -8, to: Date())!,
        amount: 120_000,
        balanceSnapshot: 16_815_000,
        paymentMethod: .banking
    )

    static let mockNetflix = BalanceTransaction(
        note: "Netflix",
        transactionType: .expense,
        occurredAt: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
        amount: 260_000,
        balanceSnapshot: 16_555_000,
        paymentMethod: .banking
    )

    static let mockGroceries = BalanceTransaction(
        note: "Groceries",
        transactionType: .expense,
        occurredAt: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
        amount: 14_705_000,
        balanceSnapshot: 1_850_000,
        paymentMethod: .banking
    )
}
