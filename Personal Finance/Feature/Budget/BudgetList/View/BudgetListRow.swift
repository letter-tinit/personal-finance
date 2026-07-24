//
//  BudgetListRow.swift
//  Personal Finance
//
//  Created by TiniT on 23/7/26.
//

import SwiftUI

struct BudgetListRow: View {
    let budget: Budget
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(budget.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Image(systemName: "chart.pie.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.orange)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(budget.income.formattedVND)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                
                Text(budget.method.localizationKey.localized)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .borderedBackground(fillColor: budget.method.color.opacity(0.3), lineWidth: 0)
            }
            
        }
        .padding(.vertical, 8)
    }
}
