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
    private var transactions: [Transaction] = []
    
    var title = "balance".localized
    var isCreateNewBalancePresented: Bool = false
    var balance: Balance {
        Balance(transactions: transactions)
    }
    var toastMessage: ToastMessage?
    var selectedMonth: Date = Date()

    init(repository: BalanceRepository) {
        self.repository = repository
    }
    
    func fetchTransactionByMonth() {
        do {
            transactions = try repository.fetchTransactionsByMonth(in: selectedMonth)
        } catch {
            showError(error.localizedDescription)
        }
    }
    
    func months() -> [Date] {
        firstTransactionMonth().generateMonthsTo(to: .now)
    }
    
    func addTransaction(_ transaction: Transaction) {
        do {
            try repository.addTransaction(transaction)
        } catch {
            showError(error.localizedDescription)
        }
    }
    
    func removeTransaction(_ transaction: Transaction) {
        do {
            try repository.deleteTransaction(transaction)
        } catch {
            showError(error.localizedDescription)
        }
    }
    
    func updateTransaction(_ transaction: Transaction) {
        do {
            try repository.updateTransaction(transaction)
        } catch {
            showError(error.localizedDescription)
        }
    }
}

private extension BalanceViewModel {
    func showError(_ message: String) {
        toastMessage = ToastMessage(text: message, type: .failure)
    }
    
    func firstTransactionMonth() -> Date {
        Calendar.current.date(byAdding: .month, value: -3, to: .now) ?? Date()
//        do {
//            return try repository.firstTransactionMonth() ?? Date()
//        } catch {
//            showError(error.localizedDescription)
//            return Date()
//        }
    }
}
