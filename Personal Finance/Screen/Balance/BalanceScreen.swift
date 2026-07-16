//
//  BalanceScreen.swift
//  Personal Finance
//
//  Created by TiniT on 16/7/26.
//

import SwiftUI

struct BalanceScreen: View {
    let balance: Balance = .mock
    
    var body: some View {
        VStack {
            // MARK: - BALANCE VIEW
            BalanceCard(balance: balance)
            
            // MARK: - TRANSACTIONS
            BalanceList(transactions: balance.transactions)
        }
        .padding(.horizontal)
    }
}

#Preview {
    BalanceScreen()
}
