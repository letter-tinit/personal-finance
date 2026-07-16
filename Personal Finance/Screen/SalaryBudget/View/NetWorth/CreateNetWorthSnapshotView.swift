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
    @State private var errorMessage: String?

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

            if let errorMessage {
                Section {
                    Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                        .foregroundStyle(Color.Common.failure)
                }
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
                errorMessage = "networth.snapshot.form.error.invalidYear".localized
            case .duplicateMonth:
                errorMessage = "networth.snapshot.form.error.duplicateMonth".localized
            }
        } catch {
            errorMessage = "networth.snapshot.form.error.save".localized
        }
    }
}

//#Preview {
//    NavigationStack {
//        CreateNetWorthSnapshotView(
//            existingSnapshots: [.july2026],
//            year: 2026,
//            suggestedMonth: Calendar.current.nextMonth(after: .july2026.asOfDate),
//            onCreate: { _ in }
//        )
//    }
//}
