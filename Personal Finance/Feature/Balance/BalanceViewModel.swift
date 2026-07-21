//
//  BalanceViewModel.swift
//  Personal Finance
//
//  Created by TiniT on 20/7/26.
//

import Foundation

@Observable
final class BalanceViewModel {
    private let repository: BalanceRepository
    
    var errorMessage: String?
    
    init(repository: BalanceRepository) {
        self.repository = repository
    }
    
    func addTransaction(_ transaction: Transaction) {
        do {
            try repository.addTransaction(transaction)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func removeTransaction(_ transaction: Transaction) {
        do {
            try repository.deleteTransaction(transaction)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateTransaction(_ transaction: Transaction) {
        do {
            try repository.updateTransaction(transaction)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
