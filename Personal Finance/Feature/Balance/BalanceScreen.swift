//
//  BalanceScreen.swift
//  Personal Finance
//
//  Created by TiniT on 16/7/26.
//

import SwiftUI
import SwiftData

struct BalanceScreen: View {
    @State private var viewModel: BalanceViewModel
    @State var router: BalanceRouter = BalanceRouter()
    
    init(_ viewModel: BalanceViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        if let balance = viewModel.balance {
            VStack {
                // MARK: - BALANCE VIEW
                BalanceCard(balance: balance)
                
                // MARK: - TRANSACTIONS
                BalanceList(transactions: balance.transactions)
            }
            .padding(.horizontal)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.addTransaction(.mockLunch)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    BalanceScreen(PreviewHelper.makeBalanceViewModel())
        .modelContainer(
            PreviewContainer.shared.container
        )
}
