//
//  Aircraft.swift
//  ClearedToPlan
//
//  Aircraft profile data model matching web app structure
//

import Foundation

struct Aircraft: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String // makeModel in web app
    var registration: String // tailNumber in web app
    var type: String // aircraft type (C-172S, PA-28-180, etc.)
    var notes: String?

    // Empty Weight & Balance
    var emptyWeight: Double // pounds
    var emptyMoment: Double // pound-inches

    // Weight Limits
    var maxRampWeight: Double?
    var maxTakeoffWeight: Double?
    var maxLandingWeight: Double?

    // Fuel
    var usableFuelGallons: Double
    var fuelDensityLbPerGal: Double // typically 6.0 for avgas

    // Weight & Balance Stations
    var stations: [Station]

    // CG Envelopes (supports both normal and utility categories)
    var normalEnvelope: [EnvelopePoint]
    var utilityEnvelope: [EnvelopePoint]?

    // Performance Data
    var performance: PerformanceData

    // Metadata
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String = "",
        registration: String = "",
        type: String = "",
        notes: String? = nil,
        emptyWeight: Double = 0,
        emptyMoment: Double = 0,
        maxRampWeight: Double? = nil,
        maxTakeoffWeight: Double? = nil,
        maxLandingWeight: Double? = nil,
        usableFuelGallons: Double = 0,
        fuelDensityLbPerGal: Double = 6.0,
        stations: [Station] = [],
        normalEnvelope: [EnvelopePoint] = [],
        utilityEnvelope: [EnvelopePoint]? = nil,
        performance: PerformanceData = PerformanceData(),
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.registration = registration
        self.type = type
        self.notes = notes
        self.emptyWeight = emptyWeight
        self.emptyMoment = emptyMoment
        self.maxRampWeight = maxRampWeight
        self.maxTakeoffWeight = maxTakeoffWeight
        self.maxLandingWeight = maxLandingWeight
        self.usableFuelGallons = usableFuelGallons
        self.fuelDensityLbPerGal = fuelDensityLbPerGal
        self.stations = stations
        self.normalEnvelope = normalEnvelope
        self.utilityEnvelope = utilityEnvelope
        self.performance = performance
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // Helper to get empty arm from empty moment
    var emptyArm: Double {
        guard emptyWeight > 0 else { return 0 }
        return emptyMoment / emptyWeight
    }
}

// MARK: - Station

struct Station: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var armIn: Double // arm in inches from datum
    var maxWeightLb: Double? // optional max weight for this station

    init(
        id: UUID = UUID(),
        name: String = "",
        armIn: Double = 0,
        maxWeightLb: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.armIn = armIn
        self.maxWeightLb = maxWeightLb
    }
}

// MARK: - Envelope Point

struct EnvelopePoint: Codable, Equatable {
    var weightLb: Double
    var cgIn: Double // CG position in inches from datum

    init(weightLb: Double = 0, cgIn: Double = 0) {
        self.weightLb = weightLb
        self.cgIn = cgIn
    }
}

// MARK: - Performance Data

struct PerformanceData: Codable, Equatable {
    // Cruise Performance (optional)
    var cruisePerformance: [CruisePerformance]

    // Takeoff Performance
    var takeoffGroundRoll: Double? // feet
    var takeoffOver50ft: Double? // feet

    // Landing Performance
    var landingGroundRoll: Double? // feet
    var landingOver50ft: Double? // feet

    init(
        cruisePerformance: [CruisePerformance] = [],
        takeoffGroundRoll: Double? = nil,
        takeoffOver50ft: Double? = nil,
        landingGroundRoll: Double? = nil,
        landingOver50ft: Double? = nil
    ) {
        self.cruisePerformance = cruisePerformance
        self.takeoffGroundRoll = takeoffGroundRoll
        self.takeoffOver50ft = takeoffOver50ft
        self.landingGroundRoll = landingGroundRoll
        self.landingOver50ft = landingOver50ft
    }
}

// MARK: - Cruise Performance

struct CruisePerformance: Codable, Equatable, Identifiable {
    let id: UUID
    var rpm: Int
    var altitudeFt: Int
    var tasKt: Int // true airspeed in knots
    var fuelBurnGPH: Double // fuel burn in gallons per hour

    init(
        id: UUID = UUID(),
        rpm: Int = 0,
        altitudeFt: Int = 0,
        tasKt: Int = 0,
        fuelBurnGPH: Double = 0
    ) {
        self.id = id
        self.rpm = rpm
        self.altitudeFt = altitudeFt
        self.tasKt = tasKt
        self.fuelBurnGPH = fuelBurnGPH
    }
}
