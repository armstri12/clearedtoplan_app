//
//  NavigationLog.swift
//  ClearedToPlan
//
//  Navigation log models
//

import Foundation

struct NavigationLeg: Codable, Identifiable {
    let id: UUID
    var from: String
    var to: String
    var altitude: Int
    var course: Int
    var distance: Double

    // Wind
    var windDirection: Int
    var windSpeed: Int

    // Calculated fields
    var groundSpeed: Double
    var timeEnRoute: TimeInterval // seconds
    var fuelBurn: Double

    init(
        id: UUID = UUID(),
        from: String = "",
        to: String = "",
        altitude: Int = 0,
        course: Int = 0,
        distance: Double = 0,
        windDirection: Int = 0,
        windSpeed: Int = 0,
        groundSpeed: Double = 0,
        timeEnRoute: TimeInterval = 0,
        fuelBurn: Double = 0
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.altitude = altitude
        self.course = course
        self.distance = distance
        self.windDirection = windDirection
        self.windSpeed = windSpeed
        self.groundSpeed = groundSpeed
        self.timeEnRoute = timeEnRoute
        self.fuelBurn = fuelBurn
    }
}

struct NavigationLogSummary {
    var legs: [NavigationLeg]

    var totalDistance: Double {
        legs.reduce(0) { $0 + $1.distance }
    }

    var totalTime: TimeInterval {
        legs.reduce(0) { $0 + $1.timeEnRoute }
    }

    var totalFuel: Double {
        legs.reduce(0) { $0 + $1.fuelBurn }
    }
}
