//
//  BalanceList.swift
//  Personal Finance
//
//  Created by TiniT on 16/7/26.
//

import SwiftUI

struct BalanceList: View {
    @Environment(BalanceViewModel.self) private var balanceViewModel: BalanceViewModel
    @State private var selectedTransaction: Transaction?
    
    let transactions: [TransactionRowModel]
    
    var body: some View {
        List(transactions) { rowModel in
            Button {
                selectedTransaction = rowModel.transaction
            } label: {
                BalanceRowItem(rowModel: rowModel)
            }
            .swipeActions(edge: .trailing) {
                Button {
                    balanceViewModel.removeTransaction(rowModel.transaction)
                } label: {
                    Label(
                        "common.delete".localized,
                        systemImage: "trash"
                    )
                }
                .tint(Color.Common.failure)
            }
            .lineSpacing(0)
        }
        .sheet(item: $selectedTransaction) { transaction in
            NavigationStack {
                BalanceFormView(transaction: transaction, onSave: balanceViewModel.updateTransaction)
            }
        }
        .contentMargins(.top, 10, for: .scrollContent)
        .listStyle(.insetGrouped)
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    BalanceList(transactions: [])
}
