//
//  MainTabScreen.swift
//  Personal Finance
//
//  Created by TiniT on 28/4/26.
//

import SwiftUI

struct MainTabScreen: View {
    @AppStorage(AppLanguage.preferenceKey) private var languageCode = AppLanguage.system.rawValue
    @State private var selectedTab: AppTab = .budget

    private var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: languageCode) ?? .system
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NetWorthListScreen()
                .tabItem {
                    Label("networth.tab.title".localized, systemImage: "chart.bar.xaxis")
                }
                .tag(AppTab.netWorth)
            
            BudgetListScreen()
                .tabItem {
                    Label("salary.budget".localized, systemImage: "wallet.bifold")
                }
                .tag(AppTab.budget)

            ProfileScreen()
                .tabItem {
                    Label("profile.tab.title".localized, systemImage: "person.crop.circle")
                }
                .tag(AppTab.profile)
        }
        .id(languageCode)
        .tint(.cyan)
        .environment(\.locale, selectedLanguage.locale)
    }
}

private enum AppTab: Hashable {
    case netWorth
    case budget
    case profile
}

#Preview {
    MainTabScreen()
}
