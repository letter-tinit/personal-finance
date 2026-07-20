//
//  MainTabScreen.swift
//  Personal Finance
//
//  Created by TiniT on 28/4/26.
//

import SwiftUI

typealias MainTabFactory = BalanceViewModelFactory
struct MainTabScreen: View {
    private let factory: MainTabFactory
    @State private var balanceViewModel: BalanceViewModel
    
    @AppStorage(AppLanguage.preferenceKey) private var languageCode = AppLanguage.system.rawValue
    @State private var selectedTab: AppTab = .balance

    private var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: languageCode) ?? .system
    }
    
    init(factory: MainTabFactory) {
        self.factory = factory
        _balanceViewModel = State(initialValue: factory.makeBalanceViewModel())
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            BalanceScreen(balanceViewModel)
                .tabItem {
                    Label(AppTab.balance.name.localized, systemImage: AppTab.balance.icon)
                }
                .tag(AppTab.balance)
            
            NetWorthListScreen()
                .tabItem {
                    Label(AppTab.netWorth.name.localized, systemImage: AppTab.netWorth.icon)
                }
                .tag(AppTab.netWorth)
            
            BudgetListScreen()
                .tabItem {
                    Label(AppTab.budget.name.localized, systemImage: AppTab.budget.icon)
                }
                .tag(AppTab.budget)

            ProfileScreen()
                .tabItem {
                    Label(AppTab.profile.name.localized, systemImage: AppTab.profile.icon)
                }
                .tag(AppTab.profile)
        }
        .id(languageCode)
        .tint(.cyan)
        .environment(\.locale, selectedLanguage.locale)
    }
}

private enum AppTab: Hashable {
    case balance
    case netWorth
    case budget
    case profile
    
    var name: String {
        switch self {
        case .balance:
            "balance"
        case .netWorth:
            "networth.tab.title"
        case .budget:
            "salary.budget"
        case .profile:
            "profile.tab.title"
        }
    }
    
    var icon: String {
        switch self {
        case .balance:
            "banknote"
        case .netWorth:
            "chart.bar.xaxis"
        case .budget:
            "wallet.bifold"
        case .profile:
            "person.crop.circle"
        }
    }
}

import SwiftData
#Preview {
    let container = AppContainer()
    
    MainTabScreen(factory: container)
        .modelContainer(container.modelContainer)
}
