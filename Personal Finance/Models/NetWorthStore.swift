//
//  NetWorthStore.swift
//  Personal Finance
//

import Foundation

enum NetWorthStoreError: Error {
    case documentsDirectoryUnavailable
}

struct NetWorthStore {
    private let fileURL: URL
    private let fileManager: FileManager
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(fileURL: URL? = nil, fileManager: FileManager = .default) throws {
        self.fileManager = fileManager

        if let fileURL {
            self.fileURL = fileURL
        } else {
            guard let documentsURL = fileManager.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first else {
                throw NetWorthStoreError.documentsDirectoryUnavailable
            }

            self.fileURL = documentsURL.appendingPathComponent("net-worth.json")
        }

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    func loadData() throws -> [NetWorthData]? {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        let data = try Data(contentsOf: fileURL)
        if let yearlyData = try? decoder.decode([NetWorthData].self, from: data) {
            try yearlyData.forEach { try $0.validate() }
            return yearlyData
        }

        let legacyData = try decoder.decode(NetWorthData.self, from: data)
        try legacyData.validate()
        return [legacyData]
    }

    func saveData(_ data: [NetWorthData]) throws {
        try data.forEach { try $0.validate() }
        try encoder.encode(data).write(to: fileURL, options: [.atomic])
    }
}
