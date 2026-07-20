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
    
    var balance: Balance?
    var errorMessage: String?
    
    init(repository: BalanceRepository) {
        self.repository = repository
        load()
    }
    
    func load() {
        errorMessage = nil
        
        do {
            self.balance = Balance(transactions: try repository.fetchTransactions())
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func addTransaction(_ transaction: BalanceTransaction) {
        do {
            try repository.addTransaction(transaction)
            load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
