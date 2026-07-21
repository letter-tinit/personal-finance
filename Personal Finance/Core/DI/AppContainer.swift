//
//  AppContainer.swift
//  Personal Finance
//
//  Created by TiniT on 20/7/26.
//

import SwiftData

final class AppContainer: BalanceViewModelFactory {

    let modelContainer: ModelContainer
    private let mainContext: ModelContext

    init(inMemory: Bool = false) {
        let config = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        modelContainer = try! ModelContainer(
            for: Transaction.self,
            configurations: config
        )
        
        mainContext = modelContainer.mainContext
    }


    func makeBalanceViewModel() -> BalanceViewModel {
        BalanceViewModel(repository: ImplBalanceRepository(modelContext: mainContext))
    }
}
