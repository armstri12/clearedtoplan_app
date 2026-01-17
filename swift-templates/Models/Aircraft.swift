//
//  Aircraft.swift
//  ClearedToPlan
//
//  Aircraft profile data model
//

import Foundation

struct Aircraft: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var registration: String
    var type: String
    var category: AircraftCategory

    // Weight & Balance
    var emptyWeight: Double
    var emptyArm: Double
    var stations: [Station]
    var envelope: [EnvelopePoint]

    // Performance
    var performanceData: PerformanceData

    // Fuel
    var fuelCapacity: Double
    var fuelBurnRate: Double // gallons per hour

    init(
        id: UUID = UUID(),
        name: String = "",
        registration: String = "",
        type: String = "",
        category: AircraftCategory = .singleEngineLand,
        emptyWeight: Double = 0,
        emptyArm: Double = 0,
        stations: [Station] = [],
        envelope: [EnvelopePoint] = [],
        performanceData: PerformanceData = PerformanceData(),
        fuelCapacity: Double = 0,
        fuelBurnRate: Double = 0
    ) {
        self.id = id
        self.name = name
        self.registration = registration
        self.type = type
        self.category = category
        self.emptyWeight = emptyWeight
        self.emptyArm = emptyArm
        self.stations = stations
        self.envelope = envelope
        self.performanceData = performanceData
        self.fuelCapacity = fuelCapacity
        self.fuelBurnRate = fuelBurnRate
    }
}

enum AircraftCategory: String, Codable, CaseIterable {
    case singleEngineLand = "Single Engine Land"
    case multiEngineLand = "Multi Engine Land"
    case singleEngineSeaplane = "Single Engine Seaplane"
    case multiEngineSeaplane = "Multi Engine Seaplane"
}

struct Station: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var arm: Double
    var maxWeight: Double

    init(
        id: UUID = UUID(),
        name: String = "",
        arm: Double = 0,
        maxWeight: Double = 0
    ) {
        self.id = id
        self.name = name
        self.arm = arm
        self.maxWeight = maxWeight
    }
}

struct EnvelopePoint: Codable, Equatable {
    var weight: Double
    var arm: Double

    init(weight: Double = 0, arm: Double = 0) {
        self.weight = weight
        self.arm = arm
    }
}

struct PerformanceData: Codable, Equatable {
    var takeoffGroundRoll: [PerformancePoint]
    var takeoffOver50Ft: [PerformancePoint]
    var landingGroundRoll: [PerformancePoint]
    var landingOver50Ft: [PerformancePoint]

    init(
        takeoffGroundRoll: [PerformancePoint] = [],
        takeoffOver50Ft: [PerformancePoint] = [],
        landingGroundRoll: [PerformancePoint] = [],
        landingOver50Ft: [PerformancePoint] = []
    ) {
        self.takeoffGroundRoll = takeoffGroundRoll
        self.takeoffOver50Ft = takeoffOver50Ft
        self.landingGroundRoll = landingGroundRoll
        self.landingOver50Ft = landingOver50Ft
    }
}

struct PerformancePoint: Codable, Equatable {
    var altitude: Double // feet
    var distance: Double // feet

    init(altitude: Double = 0, distance: Double = 0) {
        self.altitude = altitude
        self.distance = distance
    }
}
