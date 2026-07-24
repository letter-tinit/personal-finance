//
//  BudgetIncomeCardView.swift
//  Personal Finance
//
//  Created by TiniT on 23/7/26.
//

import SwiftUI

struct BudgetIncomeCardView: View {
    let budget: Budget
    var isPortrait: Bool
    
    var body: some View {
        Group {
            if isPortrait {
                VStack(alignment: .leading) {
                    Text("monthly.salary".localized)
                        .customSubHeadline()
                    
                    Text(budget.income.formattedVND)
                        .customTitle()
                    
                    Divider()
                    
                    HStack {
                        Text("budget.method".localized)
                            .customHeadline()
                        
                        Spacer()
                        
                        Text(budget.method.localizationKey.localized)
                            .customSubHeadline()
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .foregroundStyle(budget.method.color.opacity(0.12))
                            )
                    }
                }
                .shadow(color: .primary.opacity(0.3), radius: 1, x: 1, y: 1)
                .foregroundStyle(Color.Common.surface)
                .padding()
                .frame(maxWidth: .infinity)
                .borderedBackground(linearGradient: LinearGradient(
                    stops: [
                        .init(color: Color(red: 0.78, green: 0.79, blue: 0.81), location: 0.0),
                        .init(color: Color(red: 0.60, green: 0.61, blue: 0.63), location: 0.35),
                        .init(color: Color(red: 0.42, green: 0.43, blue: 0.45), location: 0.55),
                        .init(color: Color(red: 0.68, green: 0.69, blue: 0.71), location: 0.8),
                        .init(color: Color(red: 0.48, green: 0.49, blue: 0.51), location: 1.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            } else {
                Text(budget.income.formattedVND)
                    .customSubHeadline()
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .frame(width: 200, alignment: .leading)
                    .customHeadline()
                    .borderedBackground(fillColor: Color.Common.success.opacity(0.5), cornerRadius: 8, lineWidth: 0)
            }
        }
    }
}
