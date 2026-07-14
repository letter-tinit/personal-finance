//
//  BudgetListScreen.swift
//  Personal Finance
//
//  Created by TiniT on 13/7/26.
//

import SwiftUI

struct BudgetListScreen: View {
    @State private var budgetRouter = BudgetRouter()
    
    var body: some View {
        AppNavigationStack(path: $budgetRouter.path) {
            VStack {
                
                Text("budget.list.empty".localized)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        budgetRouter.push(.budget)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("budget.open.mock".localized)
                }
            }
            
        } destination: { route in
            switch route {
            case .budget:
                BudgetScreen(budget: .mock)
            }
        }
        
    }
}

#Preview {
    BudgetListScreen()
}
