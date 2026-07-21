//
//  BalanceCard.swift
//  Personal Finance
//
//  Created by TiniT on 16/7/26.
//

import SwiftUI

struct BalanceCard: View {
    @State private var isExpand: Bool = false
    
    let balance: Balance
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack {
                HStack {
                    Image(systemName: balance.symbol)
                
                    Text(balance.name.localized)
                        .customSubHeadline()
                    
                    Spacer()
                    
                    Button {
                        baseAnimation {
                            isExpand.toggle()
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .rotationEffect(.degrees(isExpand ? 90 : 0))
                    }
                }
                
                Text(balance.displayBalance)
                    .customTitle()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .foregroundStyle(balance.color)
            
            if isExpand {
                VStack {
                    let hasInflow = balance.inflow != .zero
                    let hasOutflow = balance.outflow != .zero
                    
                    Divider()
                    
                    HStack {
                        Text("balance.inflow".localized)
                        
                        Spacer()
                        
                        Text(hasInflow ? "+ \(balance.inflow.formattedVND)" : "0 ₫")
                            .foregroundStyle(Color.Common.success)
                    }
                    .customHeadline()
                    
                    HStack {
                        Text("balance.outflow".localized)
                        
                        Spacer()
                        
                        Text(hasOutflow ? "- \(balance.outflow.formattedVND)" : "0 ₫")
                            .foregroundStyle(Color.Common.failure)
                    }
                    .customHeadline()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .borderedBackground(
            linearGradient: LinearGradient(
                colors: [
                    .cyan.opacity(0.25),
                    .cyan.opacity(0.12),
                    .cyan.opacity(0.30)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            cornerRadius: 16,
            lineWidth: 0
        )
    }
}

#Preview {
    BalanceCard(balance: .init(transactions: []))
}
