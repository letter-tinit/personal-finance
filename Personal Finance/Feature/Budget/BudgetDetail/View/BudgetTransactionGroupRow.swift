//
//  BudgetTransactionGroupRow.swift
//  Personal Finance
//
//  Created by TiniT on 24/7/26.
//

import SwiftUI
import Observation

struct BudgetTransactionGroupRow: View {
    @Binding var model: BudgetDetailScreen.BudgetTransactionGroupRowModel
    @Binding var selectedTransaction: BudgetTransaction?
    @Binding var transactionPendingDeletion: BudgetTransaction?
    
    private var totalAmount: Decimal {
        model.group.transactions.reduce(Decimal.zero) { partialResult, transaction in
            partialResult + transaction.amount
        }
    }
    
    var body: some View {
        let group = model.group
        VStack {
            HStack {
                VStack {
                    Image(systemName: "\(group.date.toString(withFormat: .dayNo)).calendar")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48)
                    
                    Text(group.date.toString(withFormat: .custom("EEE")))
                        .secondarySubHeadline()
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Button {
                        baseAnimation {
                            model.isExpand.toggle()
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .rotationEffect(.degrees(
                                model.isExpand ? 90 : 0
                            ))
                    }
                    
                    Spacer()
                    
                    Text("- " + totalAmount.formattedVND)
                        .customSubTitle()
                        .foregroundStyle(Color.Common.failure)
                }
            }
            
            if model.isExpand {
                VStack {
                    Divider()
                    
                    ForEach(group.transactions) { transaction in
                        Button {
                            selectedTransaction = transaction
                        } label: {
                            BudgetTransactionItemView(transaction: transaction)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                transactionPendingDeletion = transaction
                            } label: {
                                Label("common.delete".localized, systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .borderedBackground(
            fillColor: Color(uiColor: UIColor.systemBackground),
            cornerRadius: 16,
            lineWidth: 0
        )
        .shadow(color: .primary.opacity(0.3), radius: 1)
    }
}
