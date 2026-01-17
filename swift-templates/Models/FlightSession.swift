//
//  FlightSession.swift
//  ClearedToPlan
//
//  Manages the 5-step flight planning workflow
//

import Foundation

enum PlanningStep: Int, CaseIterable, Codable {
    case aircraft = 0
    case weightBalance = 1
    case performance = 2
    case weather = 3
    case navLog = 4

    var title: String {
        switch self {
        case .aircraft: return "Aircraft Profile"
        case .weightBalance: return "Weight & Balance"
        case .performance: return "Performance"
        case .weather: return "Weather Briefing"
        case .navLog: return "Navigation Log"
        }
    }

    var iconName: String {
        switch self {
        case .aircraft: return "airplane"
        case .weightBalance: return "scalemass.fill"
        case .performance: return "gauge.medium"
        case .weather: return "cloud.sun.fill"
        case .navLog: return "map.fill"
        }
    }
}

struct FlightSession: Codable {
    var id: UUID
    var createdAt: Date
    var selectedAircraftId: UUID?
    var completedSteps: Set<PlanningStep>

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        selectedAircraftId: UUID? = nil,
        completedSteps: Set<PlanningStep> = []
    ) {
        self.id = id
        self.createdAt = createdAt
        self.selectedAircraftId = selectedAircraftId
        self.completedSteps = completedSteps
    }

    func isStepCompleted(_ step: PlanningStep) -> Bool {
        completedSteps.contains(step)
    }

    func canAccessStep(_ step: PlanningStep) -> Bool {
        // Aircraft selection is always accessible
        if step == .aircraft { return true }

        // Other steps require aircraft to be selected
        guard selectedAircraftId != nil else { return false }

        // Check if all previous steps are completed
        for previousStep in 0..<step.rawValue {
            if let previous = PlanningStep(rawValue: previousStep),
               !completedSteps.contains(previous) {
                return false
            }
        }

        return true
    }

    var progressPercentage: Double {
        let total = Double(PlanningStep.allCases.count)
        let completed = Double(completedSteps.count)
        return (completed / total) * 100
    }
}
