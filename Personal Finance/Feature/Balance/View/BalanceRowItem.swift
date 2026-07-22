//
//  BalanceRowItem.swift
//  Personal Finance
//
//  Created by TiniT on 21/7/26.
//

import SwiftUI

struct BalanceRowItem: View {
    let rowModel: TransactionRowModel
    
    var body: some View {
        let transaction = rowModel.transaction
        let color = transaction.type.color
        let sign = transaction.type == .income ? "+" : "-"
        let paymentMethod = transaction.method
        HStack {
            VStack {
                let transactionTime = transaction.occurredAt
                Text(transactionTime.toString(withFormat: .custom("d/M")))
                    .customHeadline()
                
                Text(transactionTime.toString(withFormat: .custom("yyyy")))
                    .customSubText()
                
                Text(transactionTime.toString(withFormat: .custom("EEE")))
                    .secondarySubHeadline()
            }
            
            Divider()
            
            VStack(alignment: .leading) {
                Text(transaction.title)
                    .customSubHeadline()
                    .lineLimit(nil)
                
                Text(transaction.note ?? "")
                    .secondarySubHeadline()
                    .lineLimit(nil)
                
                Spacer()
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(sign)\(transaction.amount.formattedVND)")
                    .customSubHeadline()
                    .foregroundStyle(color)
                
                Text(rowModel.balanceSnapshot.formattedVND)
                    .font(.caption)
                
                Text(paymentMethod.localizationKey.localized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .foregroundStyle(paymentMethod.color.opacity(0.3))
                    )
            }
        }
    }
}
