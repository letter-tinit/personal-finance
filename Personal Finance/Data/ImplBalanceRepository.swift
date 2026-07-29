//
//  ImplBalanceRepository.swift
//  Personal Finance
//
//  Created by TiniT on 20/7/26.
//

import Foundation
import SwiftData

final class ImplBalanceRepository: BalanceRepository {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchTransactions() throws -> [Transaction] {
        let descriptor = FetchDescriptor<Transaction>(
            sortBy: [SortDescriptor(\.occurredAt, order: .reverse)]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    func fetchTransactionsByMonth(in month: Date) throws -> [Transaction] {
        let start = month.startOfMonth
        let end = Calendar.current.date(byAdding: .month, value: 1, to: start)!

        let predicate = #Predicate<Transaction> { transaction in
            transaction.occurredAt >= start && transaction.occurredAt < end
        }
        
        let descriptor = FetchDescriptor<Transaction>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.occurredAt, order: .reverse)]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    func firstTransactionMonth() throws -> Date? {
        var descriptor = FetchDescriptor<Transaction>(
            sortBy: [
                SortDescriptor(\.occurredAt, order: .forward)
            ]
        )
        
        descriptor.fetchLimit = 1
        
        return try modelContext.fetch(descriptor)
            .first?
            .occurredAt
            .startOfMonth
    }
    
    func addTransaction(_ transaction: Transaction) throws {
        modelContext.insert(transaction)
        try save()
    }
    
    func updateTransaction(_ transaction: Transaction) throws {
        try save()
    }
    
    func deleteTransaction(_ transaction: Transaction) throws {
        modelContext.delete(transaction)
        try save()
    }
    
    private func save() throws {
        try modelContext.save()
    }
}
