//
//  NetWorthItemFormView.swift
//  Personal Finance
//

import SwiftUI

struct NetWorthItemFormView: View {
    @Environment(\.dismiss) private var dismiss

    let titleKey: String
    let reuseHelpKey: String?
    let onSave: (ValidatedNetWorthItemInput) throws -> Void
    let onDelete: (() throws -> Void)?

    @State private var formState: NetWorthItemFormState
    @State private var errorMessage: String?
    @State private var isDeleteConfirmationPresented = false
    @FocusState private var focusedField: Field?

    init(
        initialState: NetWorthItemFormState = NetWorthItemFormState(),
        titleKey: String = "networth.item.form.title",
        reuseHelpKey: String? = nil,
        onSave: @escaping (ValidatedNetWorthItemInput) throws -> Void,
        onDelete: (() throws -> Void)? = nil
    ) {
        var formattedState = initialState
        formattedState.amountText = CurrencyInputFormatter.format(initialState.amountText)

        self.titleKey = titleKey
        self.reuseHelpKey = reuseHelpKey
        self.onSave = onSave
        self.onDelete = onDelete
        _formState = State(initialValue: formattedState)
    }

    var body: some View {
        Form {
            Section("networth.item.form.section".localized) {
                Picker(
                    "networth.item.form.category".localized,
                    selection: $formState.category
                ) {
                    ForEach(NetWorthCategory.allCases, id: \.self) { category in
                        Text(category.localizationKey.localized)
                            .tag(category)
                    }
                }

                TextField(
                    "networth.item.form.name".localized,
                    text: $formState.name
                )
                .focused($focusedField, equals: .name)

                TextField(
                    "networth.item.form.amount".localized,
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

                Text("networth.item.form.amount.help".localized)
                    .secondarySubHeadline()

                if let reuseHelpKey {
                    Text(reuseHelpKey.localized)
                        .secondarySubHeadline()
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
                    Button("networth.item.form.delete".localized, role: .destructive) {
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

                Button("keyboard.done".localized) {
                    focusedField = nil
                }
            }
        }
        .confirmationDialog(
            "networth.item.delete.confirmation.title".localized,
            isPresented: $isDeleteConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button(
                "common.delete".localized,
                role: .destructive
            ) {
                deleteItem()
            }

            Button("common.cancel".localized, role: .cancel) {}
        } message: {
            Text("networth.item.delete.confirmation.message".localized)
        }
    }
}

private extension NetWorthItemFormView {
    enum Field: Hashable {
        case name
        case amount
    }

    func save() {
        do {
            try onSave(formState.validatedInput())
            dismiss()
        } catch let error as NetWorthItemFormValidationError {
            errorMessage = error.localizationKey.localized
        } catch {
            errorMessage = "networth.item.form.error.save".localized
        }
    }

    func deleteItem() {
        do {
            try onDelete?()
            dismiss()
        } catch {
            errorMessage = "networth.item.form.error.delete".localized
        }
    }
}

private extension NetWorthItemFormValidationError {
    var localizationKey: String {
        switch self {
        case .nameRequired:
            "networth.item.form.error.name"
        case .invalidAmount:
            "networth.item.form.error.amount"
        }
    }
}

#Preview {
    NavigationStack {
        NetWorthItemFormView(onSave: { _ in })
    }
}
