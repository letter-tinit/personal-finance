//
//  BalanceCard.swift
//  Personal Finance
//
//  Created by TiniT on 16/7/26.
//

import SwiftUI

struct BalanceCard: View {
    let balance: Balance
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                HStack {
                    Image(systemName: balance.symbol)
                
                    Text(balance.name.localized)
                        .customSubHeadline()
                    
                    Spacer()
                }
                
                Text(balance.displayBalance)
                    .customTitle()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .foregroundStyle(balance.color)
            
            Divider()
                .padding(.horizontal, -16)
            
            VStack {
                let hasInflow = balance.inflow != .zero
                let hasOutflow = balance.outflow != .zero
                
                HStack {
                    Text("balance.inflow".localized)
                    
                    Spacer()
                    
                    Text(hasInflow ? "+ \(balance.inflow.formattedVND)" : "0")
                        .foregroundStyle(Color.Common.success)
                }
                .customHeadline()
                
                HStack {
                    Text("balance.outflow".localized)
                    
                    Spacer()
                    
                    Text(hasOutflow ? "- \(balance.outflow.formattedVND)" : "0")
                        .foregroundStyle(Color.Common.failure)
                }
                .customHeadline()
            }
            .padding(.vertical)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .borderedBackground(
            linearGradient: LinearGradient(
                colors: [
                    .pink.opacity(0.25),
                    .pink.opacity(0.12),
                    .pink.opacity(0.30)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            cornerRadius: 30,
            lineWidth: 0
        )
        .padding(.top)
    }
}

#Preview {
    BalanceCard(balance: .mock)
}
