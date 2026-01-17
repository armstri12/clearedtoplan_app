//
//  StorageService.swift
//  ClearedToPlan
//
//  Local data persistence using FileManager and JSON
//

import Foundation

@MainActor
class StorageService {
    static let shared = StorageService()

    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Generic Save/Load

    func save<T: Codable>(_ object: T, key: String) {
        do {
            let data = try encoder.encode(object)
            let url = documentsDirectory.appendingPathComponent("\(key).json")
            try data.write(to: url, options: [.atomic])
        } catch {
            print("Error saving \(key): \(error.localizedDescription)")
        }
    }

    func load<T: Codable>(key: String) -> T? {
        do {
            let url = documentsDirectory.appendingPathComponent("\(key).json")
            let data = try Data(contentsOf: url)
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Error loading \(key): \(error.localizedDescription)")
            return nil
        }
    }

    func delete(key: String) {
        do {
            let url = documentsDirectory.appendingPathComponent("\(key).json")
            if fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(at: url)
            }
        } catch {
            print("Error deleting \(key): \(error.localizedDescription)")
        }
    }

    func exists(key: String) -> Bool {
        let url = documentsDirectory.appendingPathComponent("\(key).json")
        return fileManager.fileExists(atPath: url.path)
    }

    // MARK: - Array Operations

    func saveArray<T: Codable>(_ array: [T], key: String) {
        save(array, key: key)
    }

    func loadArray<T: Codable>(key: String) -> [T] {
        return load(key: key) ?? []
    }

    // MARK: - Specific Data Operations

    func saveAircraft(_ aircraft: [Aircraft]) {
        saveArray(aircraft, key: "aircraft")
    }

    func loadAircraft() -> [Aircraft] {
        loadArray(key: "aircraft")
    }

    func deleteAircraft(id: UUID) {
        var aircraft = loadAircraft()
        aircraft.removeAll { $0.id == id }
        saveAircraft(aircraft)
    }

    // MARK: - Migration & Backup

    func exportAllData() -> Data? {
        let allData: [String: Any] = [
            "aircraft": loadAircraft(),
            "session": load(key: "flightSession") as FlightSession? ?? FlightSession(),
            "exportedAt": Date().ISO8601Format()
        ]
        return try? JSONSerialization.data(withJSONObject: allData)
    }

    func importAllData(from data: Data) throws {
        // Future implementation for backup/restore
    }

    func clearAllData() {
        let keys = ["aircraft", "flightSession"]
        keys.forEach { delete(key: $0) }
    }

    // MARK: - Debug

    func printStorageLocation() {
        print("Storage location: \(documentsDirectory.path)")
    }

    func listAllFiles() -> [String] {
        do {
            return try fileManager.contentsOfDirectory(atPath: documentsDirectory.path)
        } catch {
            print("Error listing files: \(error.localizedDescription)")
            return []
        }
    }
}
