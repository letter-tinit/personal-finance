//
//  ProfileScreen.swift
//  Personal Finance
//

import SwiftUI

struct ProfileScreen: View {
    @Environment(ProfileRouter.self) private var router
    @AppStorage(AppLanguage.preferenceKey) private var languageCode = AppLanguage.system.rawValue

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
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .navigationTitle("profile.tab.title".localized)
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
    ProfileScreen()
}
