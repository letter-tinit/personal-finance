//
//  CreateBudgetView.swift
//  Personal Finance
//
//  Created by TiniT on 15/7/26.
//

import SwiftUI

struct CreateBudgetView: View {
    @Environment(BudgetViewModel.self) private var budgetViewModel: BudgetViewModel
    @Environment(\.dismiss) private var dismiss

    let existingBudgets: [Budget]
    let templateBudget: Budget?

    @State private var formState: CreateBudgetFormState
    @State private var errorMessage: String?
    @FocusState private var focusedField: Field?
    @State private var showPicker = false

    init(
        existingBudgets: [Budget],
        templateBudget: Budget?
    ) {
        self.existingBudgets = existingBudgets
        self.templateBudget = templateBudget
        _formState = State(
            initialValue: CreateBudgetFormState(
                templateBudget: templateBudget
            )
        )
    }

    var body: some View {
        Form {
            Section {
                Button {
                    showPicker = true
                } label: {
                    Text(formState.periodStart.toString(withFormat: .monthAndYear).capitalizingFirstLetter)
                        .customHeadline()
                }

                TextField(
                    "budget.create.income".localized,
                    text: $formState.incomeText
                )
                .keyboardType(.numberPad)
                .focused($focusedField, equals: .income)
                .currencyInputFormat($formState.incomeText)

                Picker(
                    "budget.create.method".localized,
                    selection: $formState.method
                ) {
                    ForEach(BudgetMethod.allCases, id: \.self) { method in
                        Text(method.localizationKey.localized)
                            .tag(method)
                    }
                }
            } header: {
                Text("budget.create.section.setup".localized)
            } footer: {
                if !existingBudgets.isEmpty {
                    Text("budget.create.reuseValues.description".localized)
                }
            }

            if canReuseFixedExpensePlans {
                Section {
                    Toggle(
                        "budget.create.reuseFixedPlans".localized,
                        isOn: $formState.reusesFixedExpensePlans
                    )
                } footer: {
                    Text("budget.create.reuseFixedPlans.description".localized)
                }
            }

            Section("budget.create.section.preview".localized) {
                ForEach(previewBuckets, id: \.kind) { bucket in
                    HStack {
                        Label(
                            bucket.kind.localizationKey.localized,
                            systemImage: bucket.kind.systemImageName
                        )

                        Spacer()

                        VStack(alignment: .trailing) {
                            Text(bucket.amount.formattedVND)
                                .foregroundStyle(.primary)

                            Text(ratioText(for: bucket.ratio))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            if let errorMessage {
                Section {
                    Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                        .foregroundStyle(Color.Common.failure)
                }
            }
        }
        .navigationTitle("budget.create.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .sheet(isPresented: $showPicker) {
            let currentYear = Calendar.current.component(.year, from: .now)
            let yearRange = (currentYear - 100)...(currentYear + 100)
            MonthYearPickerSheet(selectedDate: $formState.periodStart, yearRange: yearRange)
                .presentationDetents([.medium])
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("common.cancel".localized) {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("budget.create.action".localized) {
                    createBudget()
                }
            }

            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button("common.done".localized) {
                    focusedField = nil
                }
            }
        }
    }
}

private extension CreateBudgetView {
    enum Field: Hashable {
        case income
    }

    var previewBuckets: [BudgetBucket] {
        let normalizedAmount = formState.incomeText.filter(\.isNumber)
        guard let income = Decimal(string: normalizedAmount), income > 0 else {
            return []
        }

        return formState.method.generateBucketByIncome(income)
    }

    var canReuseFixedExpensePlans: Bool {
        templateBudget?.fixedExpensePlans.isEmpty == false
    }

    func ratioText(for ratio: Decimal) -> String {
        "\(Int((ratio.doubleValue * 100).rounded()))%"
    }

    func createBudget() {
        do {
            let input = try formState.validatedInput(
                existingBudgets: existingBudgets
            )
            let budget = Budget.make(
                periodStart: input.periodStart,
                income: input.income,
                method: input.method
            )

            if input.reusesFixedExpensePlans,
               let templateBudget {
                budget.copyFixedExpensePlans(from: templateBudget)
            }

            budgetViewModel.createBudget(budget)
            dismiss()
        } catch let error as CreateBudgetFormValidationError {
            errorMessage = error.localizationKey.localized
        } catch {
            errorMessage = "budget.create.error.save".localized
        }
    }
}

#Preview {
    NavigationStack {
        CreateBudgetView(
            existingBudgets: [],
            templateBudget: nil
        )
    }
}
