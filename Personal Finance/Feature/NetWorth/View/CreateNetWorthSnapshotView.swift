//
//  CreateNetWorthSnapshotView.swift
//  Personal Finance
//

import SwiftUI

struct CreateNetWorthSnapshotView: View {
    @Environment(\.dismiss) private var dismiss
    
    let existingSnapshots: [NetWorthSnapshot]
    let year: Int
    let suggestedMonth: Date
    let onCreate: (Date) throws -> Void
    
    @State private var formState: CreateNetWorthSnapshotFormState
    @State private var toastMessage: ToastMessage?
    
    init(
        existingSnapshots: [NetWorthSnapshot],
        year: Int,
        suggestedMonth: Date,
        onCreate: @escaping (Date) throws -> Void
    ) {
        self.existingSnapshots = existingSnapshots
        self.year = year
        self.suggestedMonth = suggestedMonth
        self.onCreate = onCreate
        _formState = State(initialValue: CreateNetWorthSnapshotFormState(month: suggestedMonth))
    }
    
    var body: some View {
        Form {
            Section("networth.snapshot.form.section".localized) {
                DatePicker(
                    "networth.snapshot.form.month".localized,
                    selection: $formState.month,
                    displayedComponents: .date
                )
                
                Text("networth.snapshot.form.reuse.help".localized)
                    .secondarySubHeadline()
            }
        }
        .navigationTitle("networth.snapshot.form.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("common.cancel".localized) {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("networth.snapshot.form.create".localized) {
                    createSnapshot()
                }
            }
        }
        .toast(message: toastMessage)
    }
}

private extension CreateNetWorthSnapshotView {
    func createSnapshot() {
        do {
            let month = try formState.validatedMonth(
                existingSnapshots: existingSnapshots,
                year: year
            )
            try onCreate(month)
            dismiss()
        } catch let error as CreateNetWorthSnapshotFormValidationError {
            switch error {
            case .invalidYear:
                showError("networth.snapshot.form.error.invalidYear".localized)
            case .duplicateMonth:
                showError("networth.snapshot.form.error.duplicateMonth".localized)
            }
        } catch {
            showError("networth.snapshot.form.error.save".localized)
        }
    }
    
    func showError(_ message: String) {
        toastMessage = ToastMessage(text: message, type: .failure)
    }
}
