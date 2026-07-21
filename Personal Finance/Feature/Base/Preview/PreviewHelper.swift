//
//  PreviewHelper.swift
//  Personal Finance
//
//  Created by TiniT on 20/7/26.
//

import SwiftData

struct PreviewHelper {
    @MainActor
    static func makeBalanceViewModel() -> BalanceViewModel {
        let context = PreviewContainer.shared.container.mainContext
        
        let repository = ImplBalanceRepository(modelContext: context)
        
        return BalanceViewModel(repository: repository)
    }
}
