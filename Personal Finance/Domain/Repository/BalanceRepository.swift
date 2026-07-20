//
//  BalanceRepository.swift
//  Personal Finance
//
//  Created by TiniT on 20/7/26.
//

protocol BalanceRepository {
    func fetchTransactions() throws -> [BalanceTransaction]
    
    func addTransaction(_ transaction: BalanceTransaction) throws
    
    func updateTransaction(_ transaction: BalanceTransaction) throws
    
    func deleteTransaction(_ transaction: BalanceTransaction) throws
}
