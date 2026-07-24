//
//  BudgetTransactionItemView.swift
//  Personal Finance
//
//  Created by TiniT on 24/7/26.
//

import SwiftUI

struct BudgetTransactionItemView: View {
    let transaction: BudgetTransaction
    
    var body: some View {
        let isSaving = transaction.type == .income
        let color = isSaving ? Color.Common.success : Color.Common.failure
        
        VStack(alignment: .leading) {
            HStack {
                Text(transaction.title)
                
                Spacer()
                
                Text(transaction.amount.formattedVND)
            }
            .customSubHeadline()
            
            if !transaction.note.isEmpty {
                Text(transaction.note)
                    .secondarySubHeadline()
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .borderedBackground(fillColor: color.opacity(0.3), cornerRadius: 8, lineWidth: 0)
    }
}
