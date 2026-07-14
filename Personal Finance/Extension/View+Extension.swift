//
//  View+Extension.swift
//  Personal Finance
//
//  Created by TiniT on 13/7/26.
//

import SwiftUI
import UIKit

extension View {
    func baseAnimation(_ changes: @escaping () -> Void) {
        withAnimation(.spring(duration: 0.3)) {
            changes()
        }
    }
    
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.dismissKeyboard()
        }
    }
}
