//
//  BalanceFormView.swift
//  Personal Finance
//
//  Created by TiniT on 20/7/26.
//

import SwiftUI

struct BalanceFormView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = "transaction.form.title".localized
    @State private var input: TransactionInput = .template
    @State private var errorMessage: String?
    
    var onCreate: ((Transaction) -> Void)? = nil
    
    var body: some View {
        BaseScreen($title) {
            List {
                if let errorMessage {
                    Section("common.error".localized) {
                        Label(errorMessage.localized, systemImage: "exclamationmark.circle.fill")
                            .foregroundStyle(Color.Common.failure)
                    }
                }
                
                Section("Infomation") {
                    TextField("transaction.form.title", text: $input.title)
                    
                    TextField("transaction.form.amount", text: $input.amountText)
                        .keyboardType(.numberPad)
                        .currencyInputFormat($input.amountText)
                    
                    DatePicker(
                        "transaction.form.date".localized,
                        selection: $input.occurredAt,
                        displayedComponents: .date
                    )
                }
                
                Section("Preferences") {
                    Picker(
                        "transaction.form.paymentMethod".localized,
                        selection: $input.paymentMethod
                    ) {
                        ForEach(PaymentMethod.allCases, id: \.self) { method in
                            Text(method.localizationKey.localized)
                                .tag(method)
                        }
                    }
                    
                    Picker(
                        "transaction.form.transactionType".localized,
                        selection: $input.transactionType
                    ) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Text(type.localizedTitle)
                                .tag(type)
                        }
                    }
                    
                    Picker(
                        "transaction.form.category".localized,
                        selection: $input.category
                    ) {
                        ForEach(TransactionCategory.allCases, id: \.self) { category in
                            Label {
                                Text(category.localizedTitle)
                            } icon: {
                                Image(module: category.icon)
                            }
                            .tag(category)
                        }
                    }
                }
                
                Section("transaction.form.description".localized + " " + "common.optional.bracket".localized) {
                    TextEditor(text: $input.description)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        handleSave()
                    } label: {
                        Text("common.save".localized)
                    }
                }
            }
        }
    }
    
    private func handleSave() {
        do {
            onCreate?(try input.validatedInputTransaction())
            dismiss()
        } catch let error as TransactionFormValidationError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "common.error.unknown".localized
        }
    }
}

#Preview {
    NavigationStack {
        BalanceFormView()
    }
}
