//
//  ProfileBackupViewModel.swift
//  Personal Finance
//
//  Created by Codex on 22/7/26.
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
final class ProfileBackupViewModel {
    var exportDocument: PersonalFinanceBackupDocument?
    var toastMessage: ToastMessage?
    var errorMessage: String?

    private let store: PersonalFinanceBackupStore

    init(modelContext: ModelContext) {
        store = PersonalFinanceBackupStore(modelContext: modelContext)
    }

    func prepareExport() {
        do {
            errorMessage = nil
            exportDocument = PersonalFinanceBackupDocument(backup: try store.exportBackup())
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clearExport() {
        exportDocument = nil
    }

    func importBackup(from url: URL) {
        do {
            errorMessage = nil
            let scoped = url.startAccessingSecurityScopedResource()
            defer {
                if scoped {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let backup = try decoder.decode(PersonalFinanceBackup.self, from: data)
            try store.importBackup(backup)
            toastMessage = ToastMessage(text: "profile.backup.import.success".localized)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
