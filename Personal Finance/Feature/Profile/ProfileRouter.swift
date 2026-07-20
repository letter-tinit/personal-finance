//
//  ProfileRouter.swift
//  Personal Finance
//
//  Created by TiniT on 20/7/26.
//

import SwiftUI
import Observation

enum ProfileRoute: Hashable {
    case changeLanguage
}

@Observable
final class ProfileRouter: AppRouter<ProfileRoute> {
    func popToView(_ target: ProfileRoute) {
        if let index = path.lastIndex(of: target) {
            path = Array(path.prefix(index + 1))
        }
    }
}
