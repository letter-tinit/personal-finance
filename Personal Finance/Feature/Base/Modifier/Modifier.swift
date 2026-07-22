//
//  Modifier.swift
//  Personal Finance
//
//  Created by TiniT on 21/7/26.
//

import SwiftUI


// MARK: - Format currency text
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

// MARK: - Delete comfirmation
struct DeleteConfirmationDialogModifier: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let deleteAction: () -> Void

    func body(content: Content) -> some View {
        content
            .confirmationDialog(
                title,
                isPresented: $isPresented,
                titleVisibility: .visible
            ) {
                Button(
                    "common.delete".localized,
                    role: .destructive
                ) {
                    deleteAction()
                }

                Button(
                    "common.cancel".localized,
                    role: .cancel
                ) {}
            } message: {
                Text(message)
            }
    }
}

// MARK: - Toast message
struct ToastModifier: ViewModifier {
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
        
        var color: Color {
            switch self {
            case .success: .green
            case .failure: Color.Common.failure
            case .warning: .orange
            }
        }
    }
    
    @State private var visibleMessage: ToastMessage?
    
    let message: ToastMessage?
    let toastType: ToastType
    let position: Alignment
    let duration: Double

    func body(content: Content) -> some View {
        content
            .overlay(alignment: position) {
                if let visibleMessage {
                    HStack {
                        Image(module: toastType.icon)
                            .resizable()
                            .frame(width: 24, height: 24)
                        
                        Text(visibleMessage.text)
                            .customSubHeadline()
                            .lineLimit(nil)
                        
                        Spacer()
                    }
                    .foregroundStyle(toastType.color)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        Capsule()
                            .foregroundStyle(toastType.color.opacity(0.2))
                    )
                    .padding(.horizontal)
                    .padding(position == .top ? .top : .bottom, 8)
                    .transition(.move(edge: position == .top ? .top : .bottom).combined(with: .opacity))
                    .zIndex(1)
                }
            }
            .onChange(of: message) { _, newValue in
                guard let newValue else { return }

                visibleMessage = newValue

                Task {
                    try? await Task.sleep(for: .seconds(duration))

                    await MainActor.run {
                        if visibleMessage?.id == newValue.id {
                            visibleMessage = nil
                        }
                    }
                }
            }
            .animation(.easeInOut, value: visibleMessage)
    }
}
