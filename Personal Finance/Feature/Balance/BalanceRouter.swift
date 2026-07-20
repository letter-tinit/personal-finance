//
//  BalanceRouter.swift
//  Personal Finance
//
//  Created by TiniT on 20/7/26.
//

import SwiftUI
import Observation

enum BalanceRoute: Hashable {
}

@Observable
final class BalanceRouter: AppRouter<BalanceRoute> {
    func popToView(_ target: BalanceRoute) {
        if let index = path.lastIndex(of: target) {
            path = Array(path.prefix(index + 1))
        }
    }
}
