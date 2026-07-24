//
//  BudgetAllocationListView.swift
//  Personal Finance
//
//  Created by TiniT on 24/7/26.
//

import SwiftUI

struct BudgetAllocationListView: View {
    let budget: Budget
    
    var body: some View {
        AppScrollView(.vertical) {
            VStack {
                ForEach(budget.allocations) { allocation in
                    BudgetAllocationView(summary: budget.allocationSummary(for: allocation))
                }
            }
            .padding()
        }
    }
}
