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
    @Environment(BalanceRouter.self) private var router: BalanceRouter
    
    @State private var viewModel: BalanceViewModel
    
    private var isPortrait: Bool {
        verticalSizeClass == .regular
    }
    
    init(_ viewModel: BalanceViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        BaseScreen($viewModel.title) {
            VStack {
                // MARK: - BALANCE VIEW
                if isPortrait {
                    BalanceCard(balance: viewModel.balance)
                        .padding(.horizontal)
                }

                // MARK: - TRANSACTIONS
                BalanceList(transactions: viewModel.balance.transactionRows)
                    .environment(viewModel)
            }
        }
        .navigationBarTitleDisplayMode(.automatic)
        .toolbar {
            ToolbarItem(placement: .principal) {
                MonthPickerMenu(
                    selectedMonth: $viewModel.selectedMonth,
                    months: viewModel.months()
                )
            }
            
            ToolbarItem(placement: .topBarLeading) {
                if !isPortrait {
                    BalanceCard(balance: viewModel.balance)
                }
            }
            .sharedBackgroundVisibility(.hidden)
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.isCreateNewBalancePresented = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.isCreateNewBalancePresented) {
            NavigationStack {
                BalanceFormView(onSave: viewModel.addTransaction)
            }
        }
        .toast(message: viewModel.toastMessage)
        .onAppear {
            viewModel.fetchTransactionByMonth()
        }
        .onChange(of: viewModel.selectedMonth) { _, _ in
            viewModel.fetchTransactionByMonth()
        }
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
