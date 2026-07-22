//
//  BudgetStore.swift
//  Personal Finance
//
//  Created by TiniT on 15/7/26.
//

//import Foundation
//
//enum BudgetStoreError: Error {
//    case documentsDirectoryUnavailable
//}
//
//struct BudgetStore {
//    private let fileURL: URL
//    private let fileManager: FileManager
//    private let decoder: JSONDecoder
//    private let encoder: JSONEncoder
//
//    init(
//        fileURL: URL? = nil,
//        fileManager: FileManager = .default
//    ) throws {
//        self.fileManager = fileManager
//
//        if let fileURL {
//            self.fileURL = fileURL
//        } else {
//            guard let documentsURL = fileManager.urls(
//                for: .documentDirectory,
//                in: .userDomainMask
//            ).first else {
//                throw BudgetStoreError.documentsDirectoryUnavailable
//            }
//
//            self.fileURL = documentsURL.appendingPathComponent("budgets.json")
//        }
//
//        decoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .iso8601
//
//        encoder = JSONEncoder()
//        encoder.dateEncodingStrategy = .iso8601
//        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
//    }
//
//    func sloadBudgets() throws -> [Budget] {
//        guard fileManager.fileExists(atPath: fileURL.path) else {
//            return []
//        }
//
//        let data = try Data(contentsOf: fileURL)
//        return try decoder.decode([Budget].self, from: data)
//        return []
//    }
//
//    func saveBudgets(_ budgets: [Budget]) throws {
//        let data = try encoder.encode(budgets)
//        try data.write(to: fileURL, options: [.atomic])
//    }
//}
