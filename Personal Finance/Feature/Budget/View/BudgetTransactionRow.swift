//
//  BudgetTransactionRow.swift
//  Personal Finance
//
//  Created by TiniT on 23/7/26.
//

import SwiftUI

struct BudgetTransactionRow: View {
    let transaction: BudgetTransaction
    let allocation: BudgetAllocation?
    
    private var formattedAmount: String {
        let sign = transaction.type == .income ? "+" : "-"
        return sign + transaction.amount.formattedVND
    }
    
    private var amountColor: Color {
        transaction.type == .income ? Color.Common.success : Color.Common.failure
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(transaction.title)
                    .secondarySubHeadline()
                
                Spacer()
                
                Text(formattedAmount)
                    .customSubTitle()
                    .foregroundStyle(amountColor)
            }
            
            if let allocation {
                HStack(spacing: 6) {
                    Text(allocation.kind.localizationKey.localized)
                        .foregroundStyle(allocation.kind.topicColor)
                    
                    Text("•")
                    
                    Text(transaction.paymentMethod.localizationKey.localized)
                        .foregroundStyle(.secondary)
                }
                .customHeadline()
            } else {
                Text("budget.allocation.unknown".localized)
                    .customHeadline()
                    .foregroundStyle(.secondary)
            }
            
            if !transaction.note.isEmpty {
                Text(transaction.note)
                    .secondarySubHeadline()
            }
        }
        .frame(maxWidth: .infinity)
    }
}
