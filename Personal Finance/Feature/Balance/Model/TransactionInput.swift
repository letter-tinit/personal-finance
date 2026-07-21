//
//  TransactionInput.swift
//  Personal Finance
//
//  Created by TiniT on 21/7/26.
//

import Foundation

struct TransactionInput: Equatable {
    var title: String
    var description: String
    var transactionType: TransactionType
    var category: TransactionCategory
    var occurredAt: Date
    var amountText: String
    var paymentMethod: PaymentMethod
    
    static var template: TransactionInput {
        return TransactionInput.init(
            title: "",
            description: "",
            transactionType: .income,
            category: .other,
            occurredAt: .now,
            amountText: "",
            paymentMethod: .banking
        )
    }
    
    func validatedInputTransaction() throws -> Transaction {
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let normalizedAmount = amountText
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        if title.isEmpty {
            throw TransactionFormValidationError.titleRequired
        }
        
        if amountText.isEmpty {
            throw TransactionFormValidationError.amountRequired
        }

        guard let amount = Decimal(string: normalizedAmount) else {
            throw TransactionFormValidationError.invalidAmount
        }
        
        if amount <= 0 {
            throw TransactionFormValidationError.amountMustBePositive
        }

        return Transaction(
            title: title,
            note: trimmedDescription,
            type: transactionType,
            category: category,
            method: paymentMethod,
            amount: amount,
            occurredAt: occurredAt
        )
    }
}

enum TransactionFormValidationError: LocalizedError {
    case titleRequired
    case amountRequired
    case invalidAmount
    case amountMustBePositive

    var errorDescription: String? {
        switch self {
        case .titleRequired:
            "transaction.form.error.title"
        case .amountRequired:
            "transaction.form.error.amount.required"
        case .invalidAmount:
            "transaction.form.error.amount.invalid"
        case .amountMustBePositive:
            "transaction.form.error.amount.positive"
        }
    }
}
