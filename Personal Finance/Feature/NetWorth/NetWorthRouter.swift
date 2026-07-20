//
//  NetWorthRouter.swift
//  Personal Finance
//
//  Created by TiniT on 20/7/26.
//

import SwiftUI
import Observation

enum NetWorthRoute: Hashable {
    case yearNetworth(NetWorthData)
}

@Observable
final class NetWorthRouter: AppRouter<NetWorthRoute> {
    func popToView(_ target: NetWorthRoute) {
        if let index = path.lastIndex(of: target) {
            path = Array(path.prefix(index + 1))
        }
    }
}
