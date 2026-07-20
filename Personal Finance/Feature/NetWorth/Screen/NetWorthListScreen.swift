//
//  NetWorthListScreen.swift
//  Personal Finance
//

import SwiftUI

/// Entry point for yearly Net Worth data. Each row owns one year's plan and
/// monthly snapshots; `NetWorthScreen` renders the selected year's months.
struct NetWorthListScreen: View {
    @Environment(NetWorthRouter.self) private var router
    
    @State private var yearlyData: [NetWorthData] = [.july2026]
    @State private var errorMessage: String?
    @State private var hasLoadedData = false

    private let store: NetWorthStore?

    init(store: NetWorthStore? = try? NetWorthStore()) {
        self.store = store
    }
    
    var body: some View {
        List {
            ForEach(yearlyData.sorted { $0.year > $1.year }) { data in
                Button {
                    router.push(.yearNetworth(data))
                } label: {
                    NetWorthYearRow(data: data)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("networth.list.title".localized)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: createNextYear) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("networth.year.add".localized)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if let errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                    .font(.footnote)
                    .foregroundStyle(Color.Common.failure)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.regularMaterial)
            }
        }
        .task {
            loadDataIfNeeded()
        }
        .onChange(of: yearlyData) {
            saveData()
        }
    }
}

private extension NetWorthListScreen {
    func createNextYear() {
        guard let latestData = yearlyData.max(by: { $0.year < $1.year }) else {
            yearlyData = [.july2026]
            return
        }

        yearlyData.append(latestData.reusingPlan(for: latestData.year + 1))
    }

    func loadDataIfNeeded() {
        guard !hasLoadedData else {
            return
        }

        hasLoadedData = true

        guard let store else {
            errorMessage = "networth.storage.error.load".localized
            return
        }

        do {
            if let savedData = try store.loadData(), !savedData.isEmpty {
                yearlyData = savedData
            }
            errorMessage = nil
        } catch {
            errorMessage = "networth.storage.error.load".localized
        }
    }

    func saveData() {
        guard hasLoadedData,
              let store else {
            errorMessage = "networth.storage.error.save".localized
            return
        }

        do {
            try store.saveData(yearlyData)
            errorMessage = nil
        } catch {
            errorMessage = "networth.storage.error.save".localized
        }
    }
}

private struct NetWorthYearRow: View {
    let data: NetWorthData

    var body: some View {
        HStack {
            Text(String(data.year))
                .font(.headline)

            Spacer()

            Text(
                String(
                    format: "networth.year.monthCount".localized,
                    locale: .current,
                    data.snapshots.count
                )
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NetWorthListScreen(store: nil)
}
