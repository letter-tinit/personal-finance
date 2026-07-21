//
//  BalanceRepository.swift
//  Personal Finance
//
//  Created by TiniT on 20/7/26.
//

protocol BalanceRepository {
    func fetchTransactions() throws -> [Transaction]
    
    func addTransaction(_ transaction: Transaction) throws
    
    func updateTransaction(_ transaction: Transaction) throws
    
    func deleteTransaction(_ transaction: Transaction) throws
}
