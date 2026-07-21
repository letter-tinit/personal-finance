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
    let showsAllocationPicker: Bool
    let titleKey: String
    let onSave: (ValidatedBudgetTransactionInput) throws -> Void
    let onDelete: (() throws -> Void)?

    @State private var formState: TransactionFormState
    @State private var errorMessage: String?
    @State private var isDeleteConfirmationPresented = false
    @FocusState private var focusedField: Field?

    init(
        allocations: [BudgetAllocation],
        showsAllocationPicker: Bool = true,
        initialState: TransactionFormState = TransactionFormState(),
        titleKey: String = "transaction.form.title",
        onSave: @escaping (ValidatedBudgetTransactionInput) throws -> Void,
        onDelete: (() throws -> Void)? = nil
    ) {
        var formattedState = initialState
        formattedState.amountText = CurrencyInputFormatter.format(
            initialState.amountText
        )

        self.allocations = allocations
        self.showsAllocationPicker = showsAllocationPicker
        self.titleKey = titleKey
        self.onSave = onSave
        self.onDelete = onDelete
        _formState = State(initialValue: formattedState)
    }

    var body: some View {
        Form {
            Section("transaction.form.section.details".localized) {
                TextField(
                    "transaction.form.description".localized,
                    text: $formState.description
                )
                .focused($focusedField, equals: .description)

                if showsAllocationPicker {
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
                }

                TextField(
                    "transaction.form.amount".localized,
                    text: $formState.amountText
                )
                .keyboardType(.numberPad)
                .focused($focusedField, equals: .amount)
                .currencyInputFormat($formState.amountText)

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

            if onDelete != nil {
                Section {
                    Button(
                        "transaction.form.delete".localized,
                        role: .destructive
                    ) {
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
            "transaction.form.delete.confirmation.title".localized,
            isPresented: $isDeleteConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button(
                "common.delete".localized,
                role: .destructive
            ) {
                deleteTransaction()
            }

            Button("common.cancel".localized, role: .cancel) {}
        } message: {
            Text("common.delete.warning".localized)
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
        } catch let error as BudgetTransactionFormValidationError {
            errorMessage = error.localizationKey.localized
        } catch {
            errorMessage = "transaction.form.error.save".localized
        }
    }

    func deleteTransaction() {
        do {
            try onDelete?()
            dismiss()
        } catch {
            errorMessage = "transaction.form.error.delete".localized
        }
    }
}

extension BudgetTransactionFormValidationError {
    var localizationKey: String {
        switch self {
        case .descriptionRequired:
            "transaction.form.error.description"
        case .allocationRequired:
            "transaction.form.error.allocation"
        case .invalidAmount:
            "transaction.form.error.amount.positive"
        }
    }
}

extension PaymentMethod {
    var localizationKey: String {
        "payment.method.\(rawValue)"
    }
}

#Preview {
    let budget = Budget.make(
        periodStart: .now,
        income: 16_020_850,
        method: .fiftyThirtyTwenty
    )

    NavigationStack {
        TransactionFormView(
            allocations: budget.allocations,
            onSave: { _ in }
        )
    }
}
