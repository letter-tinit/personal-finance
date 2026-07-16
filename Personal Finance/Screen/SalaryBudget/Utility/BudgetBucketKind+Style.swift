//
//  BudgetBucketKind+Style.swift
//  Personal Finance
//
//  Created by TiniT on 10/7/26.
//

import SwiftUI

extension BudgetBucketKind {
    var topicColor: Color {
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

    var systemImageName: String {
        switch self {
        case .needs:
            return "house.fill"
        case .wants:
            return "sparkles"
        case .savings:
            return "dollarsign.bank.building.fill"
        case .necessities:
            return "cart.fill"
        case .financialFreedom:
            return "chart.line.uptrend.xyaxis"
        case .education:
            return "book.fill"
        case .longTermSavings:
            return "calendar.badge.clock"
        case .play:
            return "gamecontroller.fill"
        case .give:
            return "gift.fill"
        case .custom:
            return "circle.grid.2x2.fill"
        }
    }
}
