//
//  NetWorthScreen.swift
//  Personal Finance
//
//  Created by TiniT on 15/7/26.
//

import SwiftUI

struct NetWorthScreen: View {
    @Binding private var snapshot: NetWorthSnapshot
    @Binding private var plan: NetWorthPlan
    @Binding private var selectedSnapshotID: UUID
    let snapshots: [NetWorthSnapshot]
    let statusMessage: String?
    let onDeleteItem: (UUID) throws -> Void
    let onCreateSnapshot: () -> Void
    @State private var isItemFormPresented = false
    @State private var selectedItem: NetWorthPlanItem?
    @State private var isEditingUnlocked = false

    init(
        snapshot: Binding<NetWorthSnapshot>,
        plan: Binding<NetWorthPlan>,
        snapshots: [NetWorthSnapshot],
        selectedSnapshotID: Binding<UUID>,
        statusMessage: String?,
        onDeleteItem: @escaping (UUID) throws -> Void,
        onCreateSnapshot: @escaping () -> Void
    ) {
        _snapshot = snapshot
        _plan = plan
        self.snapshots = snapshots
        _selectedSnapshotID = selectedSnapshotID
        self.statusMessage = statusMessage
        self.onDeleteItem = onDeleteItem
        self.onCreateSnapshot = onCreateSnapshot
    }

    private var missingValueCount: Int {
        snapshot.missingValueCount(using: plan)
    }

    var body: some View {
        BaseScreen {
            AppScrollView(.vertical) {
                VStack(spacing: 16) {
                    header
                    summary

                    if let statusMessage {
                        Label(statusMessage, systemImage: "exclamationmark.circle.fill")
                            .font(.footnote)
                            .foregroundStyle(Color.Common.failure)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    NetWorthGroupView(
                        group: .assets,
                        snapshot: snapshot,
                        plan: plan,
                        isEditingUnlocked: isEditingUnlocked,
                        onEdit: { item in
                            selectedItem = item
                        }
                    )

                    NetWorthGroupView(
                        group: .liabilities,
                        snapshot: snapshot,
                        plan: plan,
                        isEditingUnlocked: isEditingUnlocked,
                        onEdit: { item in
                            selectedItem = item
                        }
                    )
                }
                .padding()
            }
        }
        .navigationTitle("networth.tab.title".localized)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    isEditingUnlocked.toggle()
                } label: {
                    Image(systemName: isEditingUnlocked ? "lock.open" : "lock")
                }
                .accessibilityLabel(
                    isEditingUnlocked
                        ? "networth.edit.lock".localized
                        : "networth.edit.unlock".localized
                )
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onCreateSnapshot) {
                    Image(systemName: "calendar.badge.plus")
                }
                .accessibilityLabel("networth.snapshot.form.title".localized)
                .disabled(!isEditingUnlocked)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isItemFormPresented = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("networth.item.form.add".localized)
                .disabled(!isEditingUnlocked)
            }
        }
        .sheet(isPresented: $isItemFormPresented) {
            NavigationStack {
                NetWorthItemFormView(onSave: addItem)
            }
        }
        .sheet(item: $selectedItem) { item in
            NavigationStack {
                NetWorthItemFormView(
                    initialState: NetWorthItemFormState(
                        item: item,
                        amount: snapshot.amount(for: item.id)
                    ),
                    titleKey: "networth.item.form.edit.title",
                    reuseHelpKey: "networth.item.form.edit.reuse.help",
                    onSave: { input in
                        try updateItem(itemID: item.id, input: input)
                    },
                    onDelete: {
                        try deleteItem(itemID: item.id)
                    }
                )
            }
        }
    }
}

private extension NetWorthScreen {
    func addItem(_ input: ValidatedNetWorthItemInput) throws {
        let item = plan.addItem(
            category: input.category,
            name: input.name
        )
        snapshot.setAmount(input.amount, for: item.id)
    }

    func updateItem(
        itemID: UUID,
        input: ValidatedNetWorthItemInput
    ) throws {
        try plan.updateItem(
            id: itemID,
            category: input.category,
            name: input.name
        )
        snapshot.setAmount(input.amount, for: itemID)
    }

    func deleteItem(itemID: UUID) throws {
        try onDeleteItem(itemID)
    }

    var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("networth.screen.title".localized)
                        .customHeadline()
                        .foregroundStyle(.secondary)

                    Picker(
                        "networth.snapshot.picker".localized,
                        selection: $selectedSnapshotID
                    ) {
                        ForEach(snapshots.sorted { $0.asOfDate > $1.asOfDate }) { snapshot in
                            Text(snapshot.asOfDate, format: .dateTime.month(.wide).year())
                                .tag(snapshot.id)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .accessibilityLabel("networth.snapshot.picker".localized)
                    .customSubTitle()
                }

                Spacer()

                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title2)
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)
            }

            Divider()

            Text("networth.total".localized)
                .customSubHeadline()
                .foregroundStyle(.secondary)

            Text(snapshot.netWorth(using: plan).formattedVND)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundStyle(.primary)

            if missingValueCount > 0 {
                Label(
                    String(
                        format: "networth.missing.count".localized,
                        locale: .current,
                        missingValueCount
                    ),
                    systemImage: "exclamationmark.circle.fill"
                )
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .borderedBackground(
            linearGradient: LinearGradient(
                colors: [Color.Common.background],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            cornerRadius: 20
        )
    }

    var summary: some View {
        HStack(spacing: 12) {
            NetWorthSummaryView(
                title: "networth.total.assets".localized,
                amount: snapshot.total(for: .assets, using: plan),
                tint: .green
            )

            NetWorthSummaryView(
                title: "networth.total.liabilities".localized,
                amount: snapshot.total(for: .liabilities, using: plan),
                tint: .orange
            )
        }
    }
}

private struct NetWorthSummaryView: View {
    let title: String
    let amount: Decimal
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .customSubText()
                .foregroundStyle(.secondary)

            Text(amount.formattedVND)
                .customHeadline()
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
        .borderedBackground(
            fillColor: tint.opacity(0.10),
            borderColor: tint.opacity(0.28),
            cornerRadius: 16
        )
    }
}

private struct NetWorthGroupView: View {
    let group: NetWorthGroup
    let snapshot: NetWorthSnapshot
    let plan: NetWorthPlan
    let isEditingUnlocked: Bool
    let onEdit: (NetWorthPlanItem) -> Void

    private var categories: [NetWorthCategory] {
        NetWorthCatalog.categories
            .filter { $0.category.group == group }
            .sorted { $0.displayOrder < $1.displayOrder }
            .map(\.category)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(group.localizationKey.localized, systemImage: group.systemImage)
                    .customHeadline()
                    .foregroundStyle(group.tint)

                Spacer()

                Text("networth.column.value".localized)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Divider()

            ForEach(categories, id: \.self) { category in
                NetWorthSectionView(
                    category: category,
                    items: plan.items(in: category),
                    snapshot: snapshot,
                    isEditingUnlocked: isEditingUnlocked,
                    onEdit: onEdit
                )
            }

            Divider()

            HStack {
                Text(group.totalLocalizationKey.localized)
                    .customHeadline()
                    .foregroundStyle(.primary)

                Spacer()

                Text(snapshot.total(for: group, using: plan).formattedVND)
                    .customHeadline()
                    .foregroundStyle(.primary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .borderedBackground(
            fillColor: Color.Common.background,
            borderColor: group.tint.opacity(0.25),
            cornerRadius: 20
        )
    }
}

//#Preview {
//    NavigationStack {
//        NetWorthScreen(
//            snapshot: .july2026,
//            plan: .july2026
//        )
//    }
//}
