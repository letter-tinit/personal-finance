//
//  BalanceList.swift
//  Personal Finance
//
//  Created by TiniT on 16/7/26.
//

import SwiftUI

struct BalanceList: View {
    let transactions: [BalanceTransaction]
    var body: some View {
        List(transactions, id: \.self) { transaction in
            let color = transaction.transactionType.color
            let sign = transaction.transactionType == .income ? "+" : "-"
            let paymentMethod = transaction.paymentMethod
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
                    Text(transaction.note)
                        .secondarySubHeadline()
                        .lineLimit(nil)
                    
                    Text(paymentMethod.localizationKey.localized)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .foregroundStyle(paymentMethod.color.opacity(0.3))
                        )
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(sign)\(transaction.amount.formattedVND)")
                        .customSubHeadline()
                        .foregroundStyle(color)
                    
                    Text(transaction.balanceSnapshot.formattedVND)
                        .font(.caption)
                }
            }
            .swipeActions(edge: .trailing) {
                Button {
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
        .listStyle(.inset)
        .scrollIndicators(.hidden)
    }
}

#Preview {
    BalanceList(transactions: Balance.mock.transactions)
}
