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
            return .blue
        case .wants:
            return .orange
        case .savings:
            return .green
        case .necessities:
            return .blue
        case .financialFreedom:
            return .mint
        case .education:
            return .purple
        case .longTermSavings:
            return .green
        case .play:
            return .pink
        case .give:
            return .teal
        case .custom:
            return .gray
        }
    }
}
