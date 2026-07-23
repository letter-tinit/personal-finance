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
                
                Text(budget.method.localizationKey.localized)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(budget.income.formattedVND)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 8)
    }
}
