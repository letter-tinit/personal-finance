//
//  MainTabScreen.swift
//  Personal Finance
//
//  Created by TiniT on 28/4/26.
//

import SwiftUI

typealias MainTabFactory = AppViewModelFactory

struct MainTabScreen: View {
    private let factory: MainTabFactory
    
    // MARK: - Bindable
    @State private var balanceViewModel: BalanceViewModel
    @State private var netWorthViewModel: NetWorthViewModel
    @State private var budgetViewModel: BudgetViewModel
    @State private var selectedTab: AppTab = .netWorth
    
    // MARK: - AppStorage
    @AppStorage(AppLanguage.preferenceKey) private var languageCode = AppLanguage.system.rawValue
    
    // MARK: - Router
    @State private var balanceRouter = BalanceRouter()
    @State private var netWorthRouter = NetWorthRouter()
    @State private var budgetRouter = BudgetRouter()
    @State private var profileRouter = ProfileRouter()
    
    private var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: languageCode) ?? .system
    }
    
    // MARK: - Init
    init(factory: MainTabFactory) {
        self.factory = factory
        _balanceViewModel = State(initialValue: factory.makeBalanceViewModel())
        _netWorthViewModel = State(initialValue: factory.makeNetWorthViewModel())
        _budgetViewModel = State(initialValue: factory.makeBudgetViewModel())
    }
    
    // MARK: - View
    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Balance
            AppNavigationStack(path: $balanceRouter.path) {
                BalanceScreen(balanceViewModel)
            } destination: { _ in
            }
            .tabItem {
                Label(AppTab.balance.name.localized, systemImage: AppTab.balance.icon)
            }
            .tag(AppTab.balance)
            
            // MARK: - Networth
            AppNavigationStack(path: $netWorthRouter.path) {
                NetWorthListScreen(netWorthViewModel)
                    .environment(netWorthRouter)
            } destination: { route in
                switch route {
                case .yearNetworth(let data):
                    NetWorthYearScreen(data: data)
                }
            }
            .tabItem {
                Label(AppTab.netWorth.name.localized, systemImage: AppTab.netWorth.icon)
            }
            .tag(AppTab.netWorth)
            
            // MARK: - Budget
            AppNavigationStack(path: $budgetRouter.path) {
                BudgetListScreen(budgetViewModel)
                    .environment(budgetRouter)
            } destination: { route in
                switch route {
                case .budget(let budget):
                    BudgetScreen(factory.makeBudgetDetailViewModel(budget: budget))
                }
            }
            .tabItem {
                Label(AppTab.budget.name.localized, systemImage: AppTab.budget.icon)
            }
            .tag(AppTab.budget)
            
            // MARK: - Profilte
            AppNavigationStack(path: $profileRouter.path) {
                ProfileScreen(factory: factory)
                    .environment(profileRouter)
            } destination: { route in
                switch route {
                case .changeLanguage:
                    AppSettingsScreen()
                }
            }
            .tabItem {
                Label(AppTab.profile.name.localized, systemImage: AppTab.profile.icon)
            }
            .tag(AppTab.profile)
            
        }
        .id(languageCode)
        .tint(.primary)
        .environment(\.locale, selectedLanguage.locale)
    }
}

// MARK: - Tab Enum
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
    let container = AppContainer(inMemory: true)
    
    MainTabScreen(factory: container)
        .modelContainer(container.modelContainer)
}
