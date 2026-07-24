//
//  BalanceScreen.swift
//  Personal Finance
//
//  Created by TiniT on 16/7/26.
//

import SwiftUI
import SwiftData

struct BalanceScreen: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @State var router: BalanceRouter = BalanceRouter()
    @State private var title = "balance".localized
    @State private var isCreateNewBalancePresented: Bool = false
    @State private var viewModel: BalanceViewModel
    
    private var isPortrait: Bool {
        verticalSizeClass == .regular
    }
    
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
                if isPortrait {
                    BalanceCard(balance: balance)
                        .padding(.horizontal)
                }

                // MARK: - TRANSACTIONS
                BalanceList(transactions: balance.transactionRows)
                    .environment(viewModel)
            }
        }
        .navigationBarTitleDisplayMode(.automatic)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if !isPortrait {
                    BalanceCard(balance: balance)
                }
            }
            .sharedBackgroundVisibility(.hidden)
            
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
