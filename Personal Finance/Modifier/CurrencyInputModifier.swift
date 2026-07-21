//
//  CurrencyInputModifier.swift
//  Personal Finance
//
//  Created by TiniT on 21/7/26.
//

import SwiftUI

struct CurrencyInputModifier: ViewModifier {
    @Binding var text: String
    
    func body(content: Content) -> some View {
        content
            .keyboardType(.numberPad)
            .onChange(of: text) { _, newValue in
                let formattedAmount = CurrencyInputFormatter.format(newValue)
                
                if formattedAmount != newValue {
                    text = formattedAmount
                }
            }
    }
}
