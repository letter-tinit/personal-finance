//
//  ViewModifier.swift
//  Personal Finance
//
//  Created by TiniT on 10/7/26.
//

import SwiftUI

extension View {
    @ViewBuilder
    func borderedBackground(
        linearGradient: LinearGradient? = nil,
        fillColor: Color = .clear,
        borderColor: Color = Color.Common.border,
        cornerRadius: CGFloat = 16,
        lineWidth: CGFloat = 1
    ) -> some View {
        if let linearGradient {
            background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(linearGradient)
                    .stroke(
                        borderColor,
                        lineWidth: lineWidth
                    )
            }
        } else {
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
    
    func customLargeTitle() -> some View {
        self
            .font(.largeTitle)
            .fontWeight(.bold)
    }
    
    func customTitle() -> some View {
        self
            .font(.title)
            .fontWeight(.bold)
    }
    
    func customSubTitle() -> some View {
        self
            .font(.system(size: 20))
            .fontWeight(.bold)
    }
    
    func customHeadline() -> some View {
        self
            .font(.headline)
            .fontWeight(.semibold)
    }
    
    func customSubHeadline() -> some View {
        self
            .font(.subheadline)
            .fontWeight(.semibold)
    }
    
    func secondarySubHeadline() -> some View {
        self
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
    
    func customNormalText() -> some View {
        self
            .font(.default)
            .fontWeight(.regular)
    }
    
    func customSubText() -> some View {
        self
            .font(.subheadline)
            .fontWeight(.regular)
    }
    
//    func custom
}
