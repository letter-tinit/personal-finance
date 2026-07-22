//
//  NetWorthYearScreen.swift
//  Personal Finance
//
//  Created by TiniT on 20/7/26.
//

import SwiftUI

struct NetWorthYearScreen: View {
    let data: NetWorthYear
    @State private var isSnapshotFormPresented = false
    
    init(data: NetWorthYear) {
        self.data = data
    }
    
    var body: some View {
        @Bindable var data = data
        if let snapshot = data.snapshots.first {
            NetWorthScreen(
                year: data,
                snapshot: snapshot,
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
        _ = try data.addSnapshot(for: month)
    }

    private func deleteItem(id: UUID) throws {
        try data.removeItem(id: id)
    }
}
