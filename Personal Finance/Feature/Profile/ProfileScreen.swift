//
//  ProfileScreen.swift
//  Personal Finance
//

import SwiftUI
import UniformTypeIdentifiers

struct ProfileScreen: View {
    @Environment(ProfileRouter.self) private var router
    @State private var backupViewModel: ProfileBackupViewModel
    @AppStorage(AppLanguage.preferenceKey) private var languageCode = AppLanguage.system.rawValue
    @State private var isImporting = false
    @State private var showingErrorAlert = false

    init(factory: AppViewModelFactory) {
        _backupViewModel = State(initialValue: factory.makeProfileBackupViewModel())
    }

    private var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: languageCode) ?? .system
    }
    
    var body: some View {
        BaseScreen {
            List {
                Section {
                    profileHeader
                }
                .listRowBackground(Color.clear)
                
                Section("profile.preferences".localized) {
                    Button {
                        router.push(.changeLanguage)
                    } label: {
                        Label {
                            HStack {
                                Text("settings.language".localized)
                                
                                Spacer()
                                
                                Text(selectedLanguage.localizationKey.localized)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "globe")
                                .foregroundStyle(.tint)
                        }
                    }
                }
                
                Section {
                    Button {
                        backupViewModel.prepareExport()
                        showingErrorAlert = backupViewModel.errorMessage != nil
                    } label: {
                        Label("profile.backup.export".localized, systemImage: "square.and.arrow.up")
                    }
                    
                    Button {
                        isImporting = true
                    } label: {
                        Label("profile.backup.import".localized, systemImage: "square.and.arrow.down")
                    }
                } header: {
                    Text("profile.backup".localized)
                } footer: {
                    Text("profile.backup.description".localized)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .navigationTitle("profile.tab.title".localized)
            .fileExporter(
                isPresented: Binding(
                    get: { backupViewModel.exportDocument != nil },
                    set: { presented in
                        if !presented {
                            backupViewModel.clearExport()
                        }
                    }
                ),
                document: backupViewModel.exportDocument,
                contentType: .json,
                defaultFilename: "PersonalFinanceBackup"
            ) { result in
                if case .failure = result {
                    backupViewModel.errorMessage = "profile.backup.error.save".localized
                    showingErrorAlert = true
                }
                backupViewModel.clearExport()
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    backupViewModel.importBackup(from: url)
                    showingErrorAlert = backupViewModel.errorMessage != nil
                case .failure:
                    backupViewModel.errorMessage = "profile.backup.error.invalidFile".localized
                    showingErrorAlert = true
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        router.push(.changeLanguage)
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("settings.title".localized)
                }
            }
            .alert("common.error".localized, isPresented: $showingErrorAlert) {
                Button("common.ok".localized, role: .cancel) { }
            } message: {
                Text(backupViewModel.errorMessage ?? "common.error.unknown".localized)
            }
            .toast(message: backupViewModel.toastMessage)
        }
    }
}

private extension ProfileScreen {
    var profileHeader: some View {
        VStack(spacing: 10) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 58))
                .foregroundStyle(.tint)
                .accessibilityHidden(true)

            Text("profile.header.title".localized)
                .customSubTitle()

            Text("profile.header.description".localized)
                .customSubText()
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

struct AppSettingsScreen: View {
    @AppStorage(AppLanguage.preferenceKey) private var languageCode = AppLanguage.system.rawValue

    var body: some View {
        Form {
            Section {
                Picker("settings.language".localized, selection: $languageCode) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.localizationKey.localized)
                            .tag(language.rawValue)
                    }
                }
                .pickerStyle(.navigationLink)
            } footer: {
                Text("settings.language.description".localized)
            }
        }
        .navigationTitle("settings.title".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProfileScreen(factory: AppContainer(inMemory: true))
}
