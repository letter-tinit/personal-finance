//
//  NetWorth.swift
//  Personal Finance
//
//  Created by TiniT on 15/7/26.
//

import Foundation
import Observation

/// App-owned classification. Its localized labels live in the presentation layer.
enum NetWorthCategory: String, CaseIterable, Hashable, Codable {
    case cashAndCashEquivalents
    case receivables
    case tangibleAssets
    case financialAssets
    case shortTermDebt
    case longTermDebt

    var group: NetWorthGroup {
        switch self {
        case .cashAndCashEquivalents, .receivables, .tangibleAssets, .financialAssets:
            return .assets
        case .shortTermDebt, .longTermDebt:
            return .liabilities
        }
    }
}

enum NetWorthGroup: String, CaseIterable, Hashable, Codable {
    case assets
    case liabilities
}

/// Fixed categories from the `Tài sản ròng` workbook.
/// This catalog is code-owned; users do not edit it for each month.
struct NetWorthCategoryDefinition: Identifiable, Hashable {
    let category: NetWorthCategory
    let displayOrder: Int

    var id: NetWorthCategory { category }
}

enum NetWorthCatalog {
    static let categories: [NetWorthCategoryDefinition] = [
        .init(category: .cashAndCashEquivalents, displayOrder: 1),
        .init(category: .receivables, displayOrder: 2),
        .init(category: .tangibleAssets, displayOrder: 3),
        .init(category: .financialAssets, displayOrder: 4),
        .init(category: .shortTermDebt, displayOrder: 5),
        .init(category: .longTermDebt, displayOrder: 6)
    ]
}

/// A reusable list of the user's assets and debts.
/// Example: `TV Samsung 55 inch` is a plan item, not an app hard-coded category.
struct NetWorthPlan: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var items: [NetWorthPlanItem]

    init(id: UUID = UUID(), name: String, items: [NetWorthPlanItem]) {
        self.id = id
        self.name = name
        self.items = items
    }

    func items(in category: NetWorthCategory) -> [NetWorthPlanItem] {
        items
            .filter { $0.category == category }
            .sorted { $0.displayOrder < $1.displayOrder }
    }

    @discardableResult
    mutating func addItem(
        category: NetWorthCategory,
        name: String
    ) -> NetWorthPlanItem {
        let nextDisplayOrder = (items(in: category).map(\.displayOrder).max() ?? 0) + 1
        let item = NetWorthPlanItem(
            category: category,
            name: name,
            displayOrder: nextDisplayOrder
        )
        items.append(item)
        return item
    }

    mutating func updateItem(
        id: UUID,
        category: NetWorthCategory,
        name: String
    ) throws {
        guard let index = items.firstIndex(where: { $0.id == id }) else {
            throw NetWorthPlanError.itemNotFound
        }

        let displayOrder: Int
        if items[index].category == category {
            displayOrder = items[index].displayOrder
        } else {
            displayOrder = (items(in: category).map(\.displayOrder).max() ?? 0) + 1
        }

        items[index].category = category
        items[index].name = name
        items[index].displayOrder = displayOrder
    }

    mutating func removeItem(id: UUID) throws {
        guard let index = items.firstIndex(where: { $0.id == id }) else {
            throw NetWorthPlanError.itemNotFound
        }

        items.remove(at: index)
    }
}

enum NetWorthPlanError: Error {
    case itemNotFound
}

enum NetWorthDataValidationError: Error {
    case invalidSnapshotYear
    case duplicateSnapshotMonth
    case mismatchedPlan
    case duplicateValue
    case unknownPlanItem
    case negativeAmount
}

/// A user-configured field reused for later monthly snapshots.
struct NetWorthPlanItem: Identifiable, Hashable, Codable {
    let id: UUID
    var category: NetWorthCategory
    var name: String
    var displayOrder: Int

    init(
        id: UUID = UUID(),
        category: NetWorthCategory,
        name: String,
        displayOrder: Int
    ) {
        self.id = id
        self.category = category
        self.name = name
        self.displayOrder = displayOrder
    }
}

/// One month-end net-worth measurement. It stores only values, not duplicated labels.
@Observable
final class NetWorthSnapshot: Identifiable, Hashable, Codable {
    let id: UUID
    let planID: UUID
    let asOfDate: Date
    var values: [NetWorthValue]

    init(
        id: UUID = UUID(),
        planID: UUID,
        asOfDate: Date,
        values: [NetWorthValue]
    ) {
        self.id = id
        self.planID = planID
        self.asOfDate = asOfDate
        self.values = values
    }

    func amount(for itemID: UUID) -> Decimal? {
        values.first(where: { $0.planItemID == itemID })?.amount
    }

    func setAmount(_ amount: Decimal?, for itemID: UUID) {
        if let index = values.firstIndex(where: { $0.planItemID == itemID }) {
            values[index].amount = amount
        } else {
            values.append(NetWorthValue(planItemID: itemID, amount: amount))
        }
    }

    /// Nil is deliberately treated as zero only for the workbook-equivalent subtotal.
    /// The UI can still show it as “chưa cập nhật” via `missingValueCount`.
    func total(for group: NetWorthGroup, using plan: NetWorthPlan) -> Decimal {
        plan.items
            .filter { $0.category.group == group }
            .compactMap { amount(for: $0.id) }
            .reduce(.zero, +)
    }

    func subtotal(for category: NetWorthCategory, using plan: NetWorthPlan) -> Decimal {
        plan.items(in: category)
            .compactMap { amount(for: $0.id) }
            .reduce(.zero, +)
    }

    func missingValueCount(using plan: NetWorthPlan) -> Int {
        plan.items.filter { amount(for: $0.id) == nil }.count
    }

    func netWorth(using plan: NetWorthPlan) -> Decimal {
        total(for: .assets, using: plan) - total(for: .liabilities, using: plan)
    }
    
    static func == (lhs: NetWorthSnapshot, rhs: NetWorthSnapshot) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// Nil represents a blank cell in the workbook; zero represents an explicitly entered 0.
struct NetWorthValue: Identifiable, Hashable, Codable {
    let id: UUID
    let planItemID: UUID
    var amount: Decimal?

    init(id: UUID = UUID(), planItemID: UUID, amount: Decimal?) {
        self.id = id
        self.planItemID = planItemID
        self.amount = amount
    }
}

/// One year's reusable item plan and its monthly measurements.
@Observable
final class NetWorthData: Identifiable, Hashable, Codable {
    let id: UUID
    let year: Int
    var plan: NetWorthPlan
    var snapshots: [NetWorthSnapshot]

    init(
        id: UUID = UUID(),
        year: Int,
        plan: NetWorthPlan,
        snapshots: [NetWorthSnapshot]
    ) {
        self.id = id
        self.year = year
        self.plan = plan
        self.snapshots = snapshots
    }

    static let july2026 = NetWorthData(
        id: UUID(uuidString: "2EDC59CE-1999-45CB-A4EF-F985CE5E8A95")!,
        year: 2026,
        plan: .july2026,
        snapshots: [.july2026]
    )

    /// Keeps the first saved Net Worth file readable after moving from one
    /// snapshot to a monthly collection of snapshots.
    private enum CodingKeys: String, CodingKey {
        case plan
        case snapshots
        case snapshot
        case id
        case year
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let decodedPlan = try container.decode(NetWorthPlan.self, forKey: .plan)

        let decodedSnapshots: [NetWorthSnapshot]

        if let snapshots = try container.decodeIfPresent(
            [NetWorthSnapshot].self,
            forKey: .snapshots
        ) {
            decodedSnapshots = snapshots
        } else {
            decodedSnapshots = [
                try container.decode(NetWorthSnapshot.self, forKey: .snapshot)
            ]
        }

        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()

        self.plan = decodedPlan
        self.snapshots = decodedSnapshots

        self.year = try container.decodeIfPresent(Int.self, forKey: .year)
            ?? Calendar.current.component(
                .year,
                from: decodedSnapshots.first?.asOfDate ?? Date()
            )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(plan, forKey: .plan)
        try container.encode(snapshots, forKey: .snapshots)
        try container.encode(id, forKey: .id)
        try container.encode(year, forKey: .year)
    }

    func snapshot(for id: UUID) -> NetWorthSnapshot? {
        snapshots.first { $0.id == id }
    }

    func containsSnapshot(in month: Date, calendar: Calendar = .current) -> Bool {
        snapshots.contains { calendar.isDate($0.asOfDate, equalTo: month, toGranularity: .month) }
    }

    func addSnapshot(
        for month: Date,
        calendar: Calendar = .current
    ) throws -> NetWorthSnapshot {
        let monthStart = calendar.startOfMonth(for: month)
        guard calendar.component(.year, from: monthStart) == year else {
            throw NetWorthDataValidationError.invalidSnapshotYear
        }
        guard !containsSnapshot(in: monthStart, calendar: calendar) else {
            throw NetWorthDataValidationError.duplicateSnapshotMonth
        }

        let snapshot = NetWorthSnapshot(
            planID: plan.id,
            asOfDate: monthStart,
            values: plan.items.map { NetWorthValue(planItemID: $0.id, amount: nil) }
        )
        snapshots.append(snapshot)
        return snapshot
    }

    func validate(calendar: Calendar = .current) throws {
        let planItemIDs = Set(plan.items.map(\.id))
        var snapshotMonths = Set<Date>()

        for snapshot in snapshots {
            guard snapshot.planID == plan.id else {
                throw NetWorthDataValidationError.mismatchedPlan
            }
            guard calendar.component(.year, from: snapshot.asOfDate) == year else {
                throw NetWorthDataValidationError.invalidSnapshotYear
            }

            let monthStart = calendar.startOfMonth(for: snapshot.asOfDate)
            guard snapshotMonths.insert(monthStart).inserted else {
                throw NetWorthDataValidationError.duplicateSnapshotMonth
            }

            var valueItemIDs = Set<UUID>()
            for value in snapshot.values {
                guard planItemIDs.contains(value.planItemID) else {
                    throw NetWorthDataValidationError.unknownPlanItem
                }
                guard valueItemIDs.insert(value.planItemID).inserted else {
                    throw NetWorthDataValidationError.duplicateValue
                }
                guard value.amount == nil || value.amount! >= .zero else {
                    throw NetWorthDataValidationError.negativeAmount
                }
            }
        }
    }

    func removeItem(id: UUID) throws {
        try plan.removeItem(id: id)

        for index in snapshots.indices {
            snapshots[index].values.removeAll { $0.planItemID == id }
        }
    }

    func reusingPlan(for year: Int) -> NetWorthData {
        var data = NetWorthData(
            year: year,
            plan: NetWorthPlan(
                name: plan.name,
                items: plan.items.map {
                    NetWorthPlanItem(
                        category: $0.category,
                        name: $0.name,
                        displayOrder: $0.displayOrder
                    )
                }
            ),
            snapshots: []
        )
        let firstMonth = Calendar.current.date(from: DateComponents(year: year, month: 1, day: 1))!
        try? data.addSnapshot(for: firstMonth)
        return data
    }
    
    static func == (lhs: NetWorthData, rhs: NetWorthData) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension NetWorthPlan {
    static let july2026 = NetWorthPlan(
        id: UUID(uuidString: "F2416D2D-4B7D-4C27-A564-F5C26C3D7342")!,
        name: "Tài sản ròng",
        items: [
            .init(id: UUID(uuidString: "F4830A54-3090-4BCB-8FC9-9B4D2D1B1F01")!, category: .cashAndCashEquivalents, name: "Tiền gửi thanh toán Ngân hàng", displayOrder: 1),
            .init(id: UUID(uuidString: "3AD340A2-A0EA-4C66-B8B6-3EAF1102E502")!, category: .cashAndCashEquivalents, name: "Tiền gửi Ngân hàng có kỳ hạn (Sổ tiết kiệm)", displayOrder: 2),
            .init(id: UUID(uuidString: "F49AB61C-4C59-4DCA-83A9-4DF6F1E1A703")!, category: .receivables, name: "Tiền cho vay", displayOrder: 1),
            .init(id: UUID(uuidString: "A60B3A10-38D9-43C8-A141-E01434FD5C04")!, category: .tangibleAssets, name: "TV Samsung 55 inch", displayOrder: 1),
            .init(id: UUID(uuidString: "E09A847B-85D9-4063-9FAE-4801BF885105")!, category: .tangibleAssets, name: "Xe máy", displayOrder: 2),
            .init(id: UUID(uuidString: "19FBEAA8-6BA5-4485-864D-87A44FBED606")!, category: .financialAssets, name: "Cổ phiếu", displayOrder: 1),
            .init(id: UUID(uuidString: "B7A2A909-D1E7-4D6F-AF47-516DEE7A7A07")!, category: .financialAssets, name: "Trái phiếu", displayOrder: 2),
            .init(id: UUID(uuidString: "4FB3174F-B982-4608-B3AA-B4F7DDC78808")!, category: .financialAssets, name: "Chứng chỉ Quỹ", displayOrder: 3),
            .init(id: UUID(uuidString: "93BEE528-56EE-4D7D-9CEB-3DFE498E5909")!, category: .financialAssets, name: "Bảo hiểm (tính phần hoàn lại)", displayOrder: 4),
            .init(id: UUID(uuidString: "49F9666C-1F0C-41FA-8915-3E38A6956A10")!, category: .shortTermDebt, name: "Nợ tiền tiết kiệm", displayOrder: 1)
        ]
    )
}

extension NetWorthSnapshot {
    static let july2026 = NetWorthSnapshot(
        id: UUID(uuidString: "BE3BD972-651A-4854-8367-58F813D99011")!,
        planID: NetWorthPlan.july2026.id,
        asOfDate: Calendar(identifier: .gregorian).date(
            from: DateComponents(year: 2026, month: 7, day: 1)
        )!,
        values: [
            .init(planItemID: NetWorthPlan.july2026.items[0].id, amount: 10_000_000),
            .init(planItemID: NetWorthPlan.july2026.items[1].id, amount: 15_000_000),
            .init(planItemID: NetWorthPlan.july2026.items[2].id, amount: 0),
            .init(planItemID: NetWorthPlan.july2026.items[3].id, amount: 2_800_000),
            .init(planItemID: NetWorthPlan.july2026.items[4].id, amount: 5_000_000),
            .init(planItemID: NetWorthPlan.july2026.items[5].id, amount: nil),
            .init(planItemID: NetWorthPlan.july2026.items[6].id, amount: nil),
            .init(planItemID: NetWorthPlan.july2026.items[7].id, amount: nil),
            .init(planItemID: NetWorthPlan.july2026.items[8].id, amount: nil),
            .init(planItemID: NetWorthPlan.july2026.items[9].id, amount: 3_500_000)
        ]
    )

    static let workbookMock: [NetWorthSnapshot] = [.july2026]
}
