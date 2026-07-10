//
//  ViewModifier.swift
//  Personal Finance
//
//  Created by TiniT on 10/7/26.
//

import SwiftUI

extension View {
    func borderedBackground(
        fillColor: Color = .clear,
        borderColor: Color = Color.Common.border,
        cornerRadius: CGFloat = 16,
        lineWidth: CGFloat = 1
    ) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(fillColor)
                .stroke(
                    borderColor,
                    lineWidth: lineWidth
                )
        }
    }
}
