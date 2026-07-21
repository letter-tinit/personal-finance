//
//  FixedExpensePlanFormView.swift
//  Personal Finance
//
//  Created by TiniT on 14/7/26.
//

import SwiftUI

struct FixedExpensePlanFormView: View {
    @Environment(\.dismiss) private var dismiss

    let titleKey: String
    let onSave: (ValidatedFixedExpensePlanInput) throws -> Void
    let onDelete: (() throws -> Void)?

    @State private var formState: FixedExpensePlanFormState
    @State private var errorMessage: String?
    @State private var isDeleteConfirmationPresented = false
    @FocusState private var focusedField: Field?

    init(
        initialState: FixedExpensePlanFormState = FixedExpensePlanFormState(),
        titleKey: String = "fixed.plan.form.title",
        onSave: @escaping (ValidatedFixedExpensePlanInput) throws -> Void,
        onDelete: (() throws -> Void)? = nil
    ) {
        var formattedState = initialState
        formattedState.amountText = CurrencyInputFormatter.format(
            initialState.amountText
        )

        self.titleKey = titleKey
        self.onSave = onSave
        self.onDelete = onDelete
        _formState = State(initialValue: formattedState)
    }

    var body: some View {
        Form {
            Section("fixed.plan.form.section.details".localized) {
                TextField(
                    "fixed.plan.form.name".localized,
                    text: $formState.name
                )
                .focused($focusedField, equals: .name)

                TextField(
                    "fixed.plan.form.amount".localized,
                    text: $formState.amountText
                )
                .keyboardType(.numberPad)
                .focused($focusedField, equals: .amount)
                .currencyInputFormat($formState.amountText)

                Text("fixed.plan.form.amount.help".localized)
                    .secondarySubHeadline()

                Picker(
                    "fixed.plan.form.amountType".localized,
                    selection: $formState.amountType
                ) {
                    ForEach(FixedExpensePlanAmountType.allCases, id: \.self) { type in
                        Text(type.localizationKey.localized)
                            .tag(type)
                    }
                }
            }

            if let errorMessage {
                Section {
                    Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                        .foregroundStyle(Color.Common.failure)
                }
            }

            if onDelete != nil {
                Section {
                    Button("fixed.plan.form.delete".localized, role: .destructive) {
                        isDeleteConfirmationPresented = true
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle(titleKey.localized)
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

                Button("common.done".localized) {
                    focusedField = nil
                }
            }
        }
        .confirmationDialog(
            "fixed.plan.delete.confirmation.title".localized,
            isPresented: $isDeleteConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button(
                "common.delete".localized,
                role: .destructive
            ) {
                deletePlan()
            }

            Button("common.cancel".localized, role: .cancel) {}
        } message: {
            Text("fixed.plan.delete.confirmation.message".localized)
        }
    }
}

private extension FixedExpensePlanFormView {
    enum Field: Hashable {
        case name
        case amount
    }

    func save() {
        do {
            let input = try formState.validatedInput()
            try onSave(input)
            dismiss()
        } catch let error as FixedExpensePlanFormValidationError {
            errorMessage = error.localizationKey.localized
        } catch {
            errorMessage = "fixed.plan.form.error.save".localized
        }
    }

    func deletePlan() {
        do {
            try onDelete?()
            dismiss()
        } catch {
            errorMessage = "fixed.plan.form.error.delete".localized
        }
    }
}

extension FixedExpensePlanFormValidationError {
    var localizationKey: String {
        switch self {
        case .nameRequired:
            "fixed.plan.form.error.name"
        case .invalidAmount:
            "fixed.plan.form.error.amount"
        }
    }
}

extension FixedExpensePlanAmountType {
    var localizationKey: String {
        "fixed.plan.amountType.\(rawValue)"
    }
}

#Preview {
    NavigationStack {
        FixedExpensePlanFormView(onSave: { _ in })
    }
}
