//
//  BalanceScreen.swift
//  Personal Finance
//
//  Created by TiniT on 16/7/26.
//

import SwiftUI
import SwiftData

struct BalanceScreen: View {
    @State var router: BalanceRouter = BalanceRouter()
    @State private var title = "balance".localized
    @State private var isCreateNewBalancePresented: Bool = false
    @State private var viewModel: BalanceViewModel
    
    @Query(
        sort: \Transaction.occurredAt,
        order: .reverse
    )
    private var transactions: [Transaction]
    private var balance: Balance {
        Balance(transactions: transactions)
    }
    
    init(_ viewModel: BalanceViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        BaseScreen($title) {
            VStack {
                // MARK: - BALANCE VIEW
                BalanceCard(balance: balance)
                    .padding(.horizontal)

                // MARK: - TRANSACTIONS
                BalanceList(transactions: balance.transactionRows)
                    .environment(viewModel)
            }
        }
        .navigationBarTitleDisplayMode(.automatic)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isCreateNewBalancePresented = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isCreateNewBalancePresented) {
            NavigationStack {
                BalanceFormView(onSave: viewModel.addTransaction)
            }
        }
        .toast(message: viewModel.toastMessage)
    }
    
    private func createTransaction(_ transaction: Transaction) {
        viewModel.addTransaction(transaction)
    }
}

#Preview {
    BalanceScreen(PreviewHelper.makeBalanceViewModel())
        .modelContainer(
            PreviewContainer.shared.container
        )
}
