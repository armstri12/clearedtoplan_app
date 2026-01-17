//
//  FlightHistoryService.swift
//  ClearedToPlan
//
//  Manages completed flight history
//

import Foundation

@MainActor
class FlightHistoryService {
    static let shared = FlightHistoryService()

    private let storageService = StorageService.shared
    private let historyKey = "flightHistory"

    private init() {}

    // MARK: - Load

    func loadAllFlights() -> [CompletedFlight] {
        storageService.loadArray(key: historyKey)
    }

    func loadRecentFlights(limit: Int = 10) -> [CompletedFlight] {
        let all = loadAllFlights()
        return Array(all.prefix(limit))
    }

    func loadFlight(id: UUID) -> CompletedFlight? {
        loadAllFlights().first { $0.id == id }
    }

    // MARK: - Save

    func saveCompletedFlight(_ flight: CompletedFlight) {
        var flights = loadAllFlights()

        // Remove existing if updating
        flights.removeAll { $0.id == flight.id }

        // Add new flight at beginning
        flights.insert(flight, at: 0)

        // Save
        storageService.saveArray(flights, key: historyKey)
    }

    func saveFlightsFromSession(_ session: FlightSession, aircraft: Aircraft) {
        let completedFlight = CompletedFlight(from: session, aircraft: aircraft)
        saveCompletedFlight(completedFlight)
    }

    // MARK: - Delete

    func deleteFlight(id: UUID) {
        var flights = loadAllFlights()
        flights.removeAll { $0.id == id }
        storageService.saveArray(flights, key: historyKey)
    }

    func deleteAllFlights() {
        storageService.delete(key: historyKey)
    }

    // MARK: - Copy Flight to New Session

    func copyFlightToNewSession(_ flight: CompletedFlight) -> FlightSession {
        var session = FlightSession()
        session.departureAirport = flight.departureAirport
        session.destinationAirport = flight.destinationAirport
        session.flightDate = Date() // New date for new flight
        session.selectedAircraftId = flight.aircraftId
        session.completedSteps = [] // Start fresh
        return session
    }
}
