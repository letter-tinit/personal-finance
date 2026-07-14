//
//  TransactionFormView.swift
//  Personal Finance
//
//  Created by TiniT on 14/7/26.
//

import SwiftUI

struct TransactionFormView: View {
    @Environment(\.dismiss) private var dismiss

    let allocations: [BudgetAllocation]
    let onSave: (ValidatedTransactionInput) throws -> Void

    @State private var formState = TransactionFormState()
    @State private var errorMessage: String?
    @FocusState private var focusedField: Field?

    var body: some View {
        Form {
            Section("transaction.form.section.details".localized) {
                TextField(
                    "transaction.form.description".localized,
                    text: $formState.description
                )
                .focused($focusedField, equals: .description)

                Picker(
                    "transaction.form.allocation".localized,
                    selection: $formState.allocationID
                ) {
                    Text("transaction.form.allocation.placeholder".localized)
                        .tag(nil as UUID?)

                    ForEach(allocations) { allocation in
                        Label(
                            allocation.kind.localizationKey.localized,
                            systemImage: allocation.kind.systemImageName
                        )
                        .tag(allocation.id as UUID?)
                    }
                }

                TextField(
                    "transaction.form.amount".localized,
                    text: $formState.amountText
                )
                .keyboardType(.numberPad)
                .focused($focusedField, equals: .amount)
                .onChange(of: formState.amountText) { _, newValue in
                    let formattedAmount = CurrencyInputFormatter.format(newValue)
                    if formattedAmount != newValue {
                        formState.amountText = formattedAmount
                    }
                }

                DatePicker(
                    "transaction.form.date".localized,
                    selection: $formState.occurredAt,
                    displayedComponents: .date
                )
            }

            Section("transaction.form.section.payment".localized) {
                Picker(
                    "transaction.form.paymentMethod".localized,
                    selection: $formState.paymentMethod
                ) {
                    ForEach(PaymentMethod.allCases, id: \.self) { method in
                        Text(method.localizationKey.localized)
                            .tag(method)
                    }
                }

                TextField(
                    "transaction.form.note".localized,
                    text: $formState.note,
                    axis: .vertical
                )
                .lineLimit(2...4)
                .focused($focusedField, equals: .note)
            }

            if let errorMessage {
                Section {
                    Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                        .foregroundStyle(Color.Common.failure)
                }
            }
        }
        .navigationTitle("transaction.form.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("common.cancel".localized) {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("common.save".localized) {
                    save()
                }
            }

            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button("keyboard.done".localized) {
                    focusedField = nil
                }
            }
        }
    }
}

private extension TransactionFormView {
    enum Field: Hashable {
        case description
        case amount
        case note
    }

    func save() {
        do {
            let input = try formState.validatedInput()
            try onSave(input)
            dismiss()
        } catch let error as TransactionFormValidationError {
            errorMessage = error.localizationKey.localized
        } catch {
            errorMessage = "transaction.form.error.save".localized
        }
    }
}

extension TransactionFormValidationError {
    var localizationKey: String {
        switch self {
        case .descriptionRequired:
            "transaction.form.error.description"
        case .allocationRequired:
            "transaction.form.error.allocation"
        case .invalidAmount:
            "transaction.form.error.amount"
        }
    }
}

extension PaymentMethod {
    var localizationKey: String {
        "payment.method.\(rawValue)"
    }
}

#Preview {
    NavigationStack {
        TransactionFormView(
            allocations: Budget.mock.allocations,
            onSave: { _ in }
        )
    }
}
