//
//  CalculationService.swift
//  ClearedToPlan
//
//  Aviation calculation utilities
//

import Foundation

struct CalculationService {

    // MARK: - Density Altitude

    /// Calculate density altitude
    /// - Parameters:
    ///   - pressureAltitude: Pressure altitude in feet
    ///   - temperature: Outside air temperature in Celsius
    /// - Returns: Density altitude in feet
    static func densityAltitude(pressureAltitude: Double, temperature: Double) -> Double {
        let isa = 15 - (2 * pressureAltitude / 1000) // ISA temp at altitude
        let deviation = temperature - isa
        return pressureAltitude + (120 * deviation)
    }

    /// Calculate pressure altitude from altimeter setting
    /// - Parameters:
    ///   - fieldElevation: Field elevation in feet
    ///   - altimeterSetting: Altimeter setting in inches Hg
    /// - Returns: Pressure altitude in feet
    static func pressureAltitude(fieldElevation: Double, altimeterSetting: Double) -> Double {
        let standardPressure = 29.92
        let pressureDifference = standardPressure - altimeterSetting
        return fieldElevation + (pressureDifference * 1000)
    }

    // MARK: - Performance Interpolation

    /// Linear interpolation between two points
    static func interpolate(x: Double, x1: Double, y1: Double, x2: Double, y2: Double) -> Double {
        guard x2 != x1 else { return y1 }
        return y1 + (x - x1) * (y2 - y1) / (x2 - x1)
    }

    // MARK: - Navigation Calculations

    /// Calculate ground speed
    static func groundSpeed(trueAirspeed: Double, windDirection: Double, windSpeed: Double, course: Double) -> Double {
        let headwind = windSpeed * cos(degreesToRadians(windDirection - course))
        return trueAirspeed + headwind
    }

    /// Calculate wind correction angle
    static func windCorrectionAngle(trueAirspeed: Double, windDirection: Double, windSpeed: Double, course: Double) -> Double {
        let crosswind = windSpeed * sin(degreesToRadians(windDirection - course))
        return radiansToDegrees(asin(crosswind / trueAirspeed))
    }

    /// Calculate time en route in minutes
    static func timeEnRoute(distance: Double, groundSpeed: Double) -> Double {
        guard groundSpeed > 0 else { return 0 }
        return (distance / groundSpeed) * 60 // Convert hours to minutes
    }

    /// Calculate fuel burn
    static func fuelBurn(time: Double, fuelBurnRate: Double) -> Double {
        return (time / 60) * fuelBurnRate // time in minutes, rate in gallons/hour
    }

    // MARK: - Unit Conversions

    static func degreesToRadians(_ degrees: Double) -> Double {
        degrees * .pi / 180
    }

    static func radiansToDegrees(_ radians: Double) -> Double {
        radians * 180 / .pi
    }

    static func nauticalMilesToStatuteMiles(_ nm: Double) -> Double {
        nm * 1.15078
    }

    static func statuteMilesToNauticalMiles(_ sm: Double) -> Double {
        sm / 1.15078
    }

    static func celsiusToFahrenheit(_ celsius: Double) -> Double {
        (celsius * 9/5) + 32
    }

    static func fahrenheitToCelsius(_ fahrenheit: Double) -> Double {
        (fahrenheit - 32) * 5/9
    }

    static func feetToMeters(_ feet: Double) -> Double {
        feet * 0.3048
    }

    static func metersToFeet(_ meters: Double) -> Double {
        meters / 0.3048
    }
}
