//
//  FlightSessionViewModel.swift
//  ClearedToPlan
//
//  Manages flight planning workflow state
//

import Foundation
import Combine

@MainActor
class FlightSessionViewModel: ObservableObject {
    @Published var session: FlightSession
    @Published var settings: AppSettings

    private let storageService = StorageService.shared
    private let historyService = FlightHistoryService.shared
    private let sessionKey = "currentFlightSession"
    private let settingsKey = "appSettings"

    init() {
        // Load settings
        if let saved: AppSettings = storageService.load(key: settingsKey) {
            self.settings = saved
        } else {
            self.settings = AppSettings()
        }

        // Load current session if active
        if let saved: FlightSession = storageService.load(key: sessionKey),
           saved.isActive {
            self.session = saved
        } else {
            self.session = FlightSession()
        }
    }

    // MARK: - Flight Setup

    func updateFlightSetup(
        departure: String,
        destination: String,
        aircraftId: UUID,
        date: Date = Date()
    ) {
        session.departureAirport = departure.uppercased()
        session.destinationAirport = destination.uppercased()
        session.selectedAircraftId = aircraftId
        session.flightDate = date

        if session.phase1Complete {
            session.completedSteps.insert(.setup)
        }

        saveSession()
    }

    func selectAircraft(_ aircraftId: UUID) {
        session.selectedAircraftId = aircraftId
        session.touch()
        saveSession()
    }

    // MARK: - Step Completion (Auto-detected)

    func completeStep(_ step: PlanningStep) {
        session.completedSteps.insert(step)
        session.touch()
        saveSession()
    }

    func uncompleteStep(_ step: PlanningStep) {
        session.completedSteps.remove(step)
        session.touch()
        saveSession()
    }

    func isStepCompleted(_ step: PlanningStep) -> Bool {
        session.isStepCompleted(step)
    }

    func canAccessStep(_ step: PlanningStep) -> Bool {
        session.canAccessStep(step, mode: settings.planningMode)
    }

    // MARK: - Flight Management

    func startNewFlight() {
        // Save current flight to history if it has meaningful data
        if session.phase1Complete {
            saveCurrentFlightToHistory()
        }

        // Create fresh session
        session = FlightSession()
        saveSession()
    }

    func saveCurrentFlightToHistory() {
        guard session.phase1Complete,
              let aircraftId = session.selectedAircraftId,
              let aircraft = loadAircraft(id: aircraftId) else {
            return
        }

        // Mark session as inactive
        session.isActive = false

        // Save to history
        historyService.saveFlightsFromSession(session, aircraft: aircraft)
    }

    func loadFlightFromHistory(_ flight: CompletedFlight) {
        // Save current if needed
        if session.phase1Complete {
            saveCurrentFlightToHistory()
        }

        // Create new session from history
        session = historyService.copyFlightToNewSession(flight)
        saveSession()
    }

    func resumeLastFlight() {
        // Session is already loaded if it exists
        // This method exists for semantic clarity
    }

    func resetSession() {
        session = FlightSession()
        saveSession()
    }

    // MARK: - Settings

    func updatePlanningMode(_ mode: PlanningMode) {
        settings.planningMode = mode
        saveSettings()
    }

    func completeOnboarding() {
        settings.hasCompletedOnboarding = true
        saveSettings()
    }

    func updateWeatherDisplay(_ display: WeatherDisplay) {
        settings.weatherDisplay = display
        saveSettings()
    }

    // MARK: - Persistence

    private func saveSession() {
        storageService.save(session, key: sessionKey)
    }

    private func saveSettings() {
        storageService.save(settings, key: settingsKey)
    }

    // MARK: - Helper

    private func loadAircraft(id: UUID) -> Aircraft? {
        let aircraft = storageService.loadAircraft()
        return aircraft.first { $0.id == id }
    }
}
