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
                    Menu {
                        Button("budget.open.mock.fiftyThirtyTwenty".localized) {
                            budgetRouter.push(.fiftyThirtyTwenty)
                        }
                        
                        Button("budget.open.mock.sixJars".localized) {
                            budgetRouter.push(.sixJars)
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("budget.open.mock".localized)
                }
            }
            
        } destination: { route in
            switch route {
            case .fiftyThirtyTwenty:
                BudgetScreen(budget: .mock)
            case .sixJars:
                BudgetScreen(budget: .sixJarsMock)
            }
        }
        
    }
}

#Preview {
    BudgetListScreen()
}
