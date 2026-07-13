//
//  BudgetBucketKind+Style.swift
//  Personal Finance
//
//  Created by TiniT on 10/7/26.
//

import SwiftUI

extension BudgetBucketKind {
    var progressColor: Color {
        switch self {
        case .needs:
            return .darkBlue
        case .wants:
            return .darkOrange
        case .savings:
            return .darkGreen
        case .necessities:
            return .darkBlue
        case .financialFreedom:
            return .mint
        case .education:
            return .purple
        case .longTermSavings:
            return .darkGreen
        case .play:
            return .pink
        case .give:
            return .teal
        case .custom:
            return .gray
        }
    }
}
