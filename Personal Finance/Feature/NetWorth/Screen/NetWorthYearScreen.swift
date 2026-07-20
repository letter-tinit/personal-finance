//
//  NetWorthYearScreen.swift
//  Personal Finance
//
//  Created by TiniT on 20/7/26.
//

import SwiftUI

struct NetWorthYearScreen: View {
    let data: NetWorthData
    @State private var selectedSnapshotID: UUID
    @State private var isSnapshotFormPresented = false

    init(data: NetWorthData) {
        self.data = data
        _selectedSnapshotID = State(
            initialValue: data.snapshots.max(by: { $0.asOfDate < $1.asOfDate })?.id
                ?? NetWorthSnapshot.july2026.id
        )
    }

    var body: some View {
        @Bindable var data = data
        if let snapshot = data.snapshots.first(where: { $0.id == selectedSnapshotID }) {
            NetWorthScreen(
                snapshot: snapshot,
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
        }
    }

    private var suggestedMonth: Date {
        Calendar.current.nextMonth(after: data.snapshots.max(by: { $0.asOfDate < $1.asOfDate })?.asOfDate
            ?? Calendar.current.startOfMonth(for: Date()))
    }
    private func createSnapshot(for month: Date) throws {
        let snapshot = try data.addSnapshot(for: month)
        selectedSnapshotID = snapshot.id
    }

    private func deleteItem(id: UUID) throws {
        try data.removeItem(id: id)
    }
}
