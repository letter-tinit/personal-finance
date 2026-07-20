//
//  Personal_FinanceApp.swift
//  Personal Finance
//
//  Created by TiniT on 9/7/26.
//

import SwiftUI
import SwiftData

@main
struct Personal_FinanceApp: App {
    private let container = AppContainer()
    
    var body: some Scene {
        WindowGroup {
            MainTabScreen(factory: container)
                .modelContainer(container.modelContainer)
        }
    }
}
