//
//  FlightSession.swift
//  ClearedToPlan
//
//  Manages the flight planning workflow with guided/advanced modes
//

import Foundation

enum PlanningStep: Int, CaseIterable, Codable {
    case setup = 0
    case weightBalance = 1
    case performance = 2
    case navLog = 3

    var title: String {
        switch self {
        case .setup: return "Flight Setup"
        case .weightBalance: return "Weight & Balance"
        case .performance: return "Performance"
        case .navLog: return "Navigation Log"
        }
    }

    var iconName: String {
        switch self {
        case .setup: return "airplane.departure"
        case .weightBalance: return "scalemass.fill"
        case .performance: return "gauge.medium"
        case .navLog: return "map.fill"
        }
    }

    var description: String {
        switch self {
        case .setup: return "Route and aircraft"
        case .weightBalance: return "CG calculations"
        case .performance: return "Takeoff/landing data"
        case .navLog: return "Flight plan details"
        }
    }
}

enum PlanningMode: String, Codable {
    case guided
    case advanced
}

struct FlightSession: Codable {
    var id: UUID
    var createdAt: Date
    var lastModified: Date

    // Phase 1: Flight Setup
    var departureAirport: String?
    var destinationAirport: String?
    var flightDate: Date
    var selectedAircraftId: UUID?

    // Phase 2: Planning (auto-detected completion)
    var completedSteps: Set<PlanningStep>

    // State
    var isActive: Bool // false when saved to history

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        lastModified: Date = Date(),
        departureAirport: String? = nil,
        destinationAirport: String? = nil,
        flightDate: Date = Date(),
        selectedAircraftId: UUID? = nil,
        completedSteps: Set<PlanningStep> = [],
        isActive: Bool = true
    ) {
        self.id = id
        self.createdAt = createdAt
        self.lastModified = lastModified
        self.departureAirport = departureAirport
        self.destinationAirport = destinationAirport
        self.flightDate = flightDate
        self.selectedAircraftId = selectedAircraftId
        self.completedSteps = completedSteps
        self.isActive = isActive
    }

    // MARK: - Computed Properties

    var phase1Complete: Bool {
        departureAirport != nil &&
        !departureAirport!.isEmpty &&
        destinationAirport != nil &&
        !destinationAirport!.isEmpty &&
        selectedAircraftId != nil
    }

    var routeDescription: String {
        guard let dep = departureAirport, let dest = destinationAirport else {
            return "No route set"
        }
        return "\(dep) → \(dest)"
    }

    var progressPercentage: Double {
        var total = Double(PlanningStep.allCases.count)
        var completed = Double(completedSteps.count)

        // Add phase 1 to total
        total += 1
        if phase1Complete {
            completed += 1
        }

        return (completed / total) * 100
    }

    // MARK: - Step Management

    func isStepCompleted(_ step: PlanningStep) -> Bool {
        completedSteps.contains(step)
    }

    func canAccessStep(_ step: PlanningStep, mode: PlanningMode) -> Bool {
        // Advanced mode: all steps always accessible
        if mode == .advanced {
            return true
        }

        // Guided mode: require phase 1 completion
        return phase1Complete
    }

    mutating func touch() {
        lastModified = Date()
    }
}

// MARK: - Completed Flight (History)

struct CompletedFlight: Codable, Identifiable {
    let id: UUID
    let completedAt: Date

    // Basic Info
    var departureAirport: String
    var destinationAirport: String
    var flightDate: Date
    var aircraftId: UUID
    var aircraftName: String // Cached for display
    var aircraftRegistration: String

    // Planning data snapshots
    var weightBalanceData: String? // JSON snapshot
    var performanceData: String? // JSON snapshot
    var navigationLogData: String? // JSON snapshot

    // Completion status
    var completedSteps: Set<PlanningStep>

    init(from session: FlightSession, aircraft: Aircraft) {
        self.id = session.id
        self.completedAt = Date()
        self.departureAirport = session.departureAirport ?? ""
        self.destinationAirport = session.destinationAirport ?? ""
        self.flightDate = session.flightDate
        self.aircraftId = aircraft.id
        self.aircraftName = aircraft.name
        self.aircraftRegistration = aircraft.registration
        self.completedSteps = session.completedSteps

        // Snapshots will be filled by ViewModels
        self.weightBalanceData = nil
        self.performanceData = nil
        self.navigationLogData = nil
    }

    var routeDescription: String {
        "\(departureAirport) → \(destinationAirport)"
    }

    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: flightDate)
    }
}

// MARK: - App Settings

struct AppSettings: Codable {
    var planningMode: PlanningMode
    var hasCompletedOnboarding: Bool
    var weatherDisplay: WeatherDisplay

    init(
        planningMode: PlanningMode = .guided,
        hasCompletedOnboarding: Bool = false,
        weatherDisplay: WeatherDisplay = .toolbar
    ) {
        self.planningMode = planningMode
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.weatherDisplay = weatherDisplay
    }
}

enum WeatherDisplay: String, Codable {
    case toolbar
    case tab
}
