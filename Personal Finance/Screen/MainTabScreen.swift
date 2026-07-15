//
//  MainTabScreen.swift
//  Personal Finance
//
//  Created by TiniT on 28/4/26.
//

import SwiftUI

struct MainTabScreen: View {
    var body: some View {
        TabView {
            BudgetListScreen()
                .tabItem {
                    Label("salary.budget".localized, systemImage: "wallet.bifold")
                }
            
            NetWorthPlaceholderScreen()
                .tabItem {
                    Label("networth.tab.title".localized, systemImage: "chart.bar.xaxis")
                }
        }
        .tint(.cyan)
    }
}

private struct NetWorthPlaceholderScreen: View {
    var body: some View {
        ContentUnavailableView(
            "networth.empty.title".localized,
            systemImage: "chart.bar.xaxis",
            description: Text("networth.empty.description".localized)
        )
        .padding()
    }
}

#Preview {
    MainTabScreen()
}
