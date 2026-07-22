//
//  ToastMessage.swift
//  Personal Finance
//
//  Created by TiniT on 22/7/26.
//

import Foundation

enum ToastType {
    case success
    case failure
    case warning
    
    var icon: String {
        switch self {
        case .success: "checkmark.circle.fill"
        case .failure: "exclamationmark.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        }
    }
}

struct ToastMessage: Equatable {
    let id = UUID()
    let text: String
    let type: ToastType
}
