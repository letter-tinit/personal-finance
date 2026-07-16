//
//  NetWorthListScreen.swift
//  Personal Finance
//

import SwiftUI

/// Entry point for yearly Net Worth data. Each row owns one year's plan and
/// monthly snapshots; `NetWorthScreen` renders the selected year's months.
struct NetWorthListScreen: View {
    @State private var yearlyData: [NetWorthData] = [.july2026]
    @State private var errorMessage: String?
    @State private var hasLoadedData = false

    private let store: NetWorthStore?

    init(store: NetWorthStore? = try? NetWorthStore()) {
        self.store = store
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(yearlyData.sorted { $0.year > $1.year }) { data in
                    NavigationLink(value: data.id) {
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
            .navigationDestination(for: UUID.self) { dataID in
                if let dataBinding = binding(for: dataID) {
                    NetWorthYearScreen(data: dataBinding)
                } else {
                    ContentUnavailableView(
                        "networth.year.missing".localized,
                        systemImage: "exclamationmark.triangle"
                    )
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
}

private extension NetWorthListScreen {
    func binding(for dataID: UUID) -> Binding<NetWorthData>? {
        guard let index = yearlyData.firstIndex(where: { $0.id == dataID }) else {
            return nil
        }

        return $yearlyData[index]
    }

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

private struct NetWorthYearScreen: View {
    @Binding var data: NetWorthData
    @State private var selectedSnapshotID: UUID
    @State private var isSnapshotFormPresented = false

    init(data: Binding<NetWorthData>) {
        _data = data
        _selectedSnapshotID = State(
            initialValue: data.wrappedValue.snapshots.max(by: { $0.asOfDate < $1.asOfDate })?.id
                ?? NetWorthSnapshot.july2026.id
        )
    }

    var body: some View {
        if let snapshotBinding = binding(for: selectedSnapshotID) {
            NetWorthScreen(
                snapshot: snapshotBinding,
                plan: $data.plan,
                snapshots: data.snapshots,
                selectedSnapshotID: $selectedSnapshotID,
                statusMessage: nil,
                onDeleteItem: deleteItem,
                onCreateSnapshot: {
                    isSnapshotFormPresented = true
                }
            )
            .sheet(isPresented: $isSnapshotFormPresented) {
                NavigationStack {
                    CreateNetWorthSnapshotView(
                        existingSnapshots: data.snapshots,
                        year: data.year,
                        suggestedMonth: suggestedMonth,
                        onCreate: createSnapshot
                    )
                }
            }
        } else {
            ContentUnavailableView(
                "networth.list.empty".localized,
                systemImage: "calendar.badge.exclamationmark"
            )
        }
    }

    private var suggestedMonth: Date {
        Calendar.current.nextMonth(after: data.snapshots.max(by: { $0.asOfDate < $1.asOfDate })?.asOfDate
            ?? Calendar.current.startOfMonth(for: Date()))
    }

    private func binding(for snapshotID: UUID) -> Binding<NetWorthSnapshot>? {
        guard let index = data.snapshots.firstIndex(where: { $0.id == snapshotID }) else {
            return nil
        }

        return $data.snapshots[index]
    }

    private func createSnapshot(for month: Date) throws {
        let snapshot = try data.addSnapshot(for: month)
        selectedSnapshotID = snapshot.id
    }

    private func deleteItem(id: UUID) throws {
        try data.removeItem(id: id)
    }
}

#Preview {
    NetWorthListScreen(store: nil)
}
