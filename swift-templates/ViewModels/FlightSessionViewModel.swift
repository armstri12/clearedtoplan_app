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

    private let storageService: StorageService
    private let storageKey = "flightSession"

    init(storageService: StorageService = StorageService.shared) {
        self.storageService = storageService

        // Load existing session or create new one
        if let saved: FlightSession = storageService.load(key: storageKey) {
            self.session = saved
        } else {
            self.session = FlightSession()
        }
    }

    func selectAircraft(_ aircraftId: UUID) {
        session.selectedAircraftId = aircraftId
        saveSession()
    }

    func completeStep(_ step: PlanningStep) {
        session.completedSteps.insert(step)
        saveSession()
    }

    func uncompleteStep(_ step: PlanningStep) {
        session.completedSteps.remove(step)
        // Also uncomplete all subsequent steps
        for subsequentStep in PlanningStep.allCases where subsequentStep.rawValue > step.rawValue {
            session.completedSteps.remove(subsequentStep)
        }
        saveSession()
    }

    func isStepCompleted(_ step: PlanningStep) -> Bool {
        session.isStepCompleted(step)
    }

    func canAccessStep(_ step: PlanningStep) -> Bool {
        session.canAccessStep(step)
    }

    func resetSession() {
        session = FlightSession()
        saveSession()
    }

    func startNewFlight() {
        // Keep aircraft selection but reset completion
        let currentAircraftId = session.selectedAircraftId
        session = FlightSession(selectedAircraftId: currentAircraftId)
        saveSession()
    }

    private func saveSession() {
        storageService.save(session, key: storageKey)
    }
}
