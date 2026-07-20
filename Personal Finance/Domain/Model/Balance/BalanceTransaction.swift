//
//  BalanceTransaction.swift
//  Personal Finance
//
//  Created by TiniT on 20/7/26.
//

import SwiftData
import Foundation

@Model
final class BalanceTransaction {
    var note: String
    var transactionType: TransactionType
    var occurredAt: Date
    var amount: Decimal
    var balanceSnapshot: Decimal
    var paymentMethod: PaymentMethod
    
    init(note: String, transactionType: TransactionType, occurredAt: Date, amount: Decimal, balanceSnapshot: Decimal, paymentMethod: PaymentMethod) {
        self.note = note
        self.transactionType = transactionType
        self.occurredAt = occurredAt
        self.amount = amount
        self.balanceSnapshot = balanceSnapshot
        self.paymentMethod = paymentMethod
    }
}
