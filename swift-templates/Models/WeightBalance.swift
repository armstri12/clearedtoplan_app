//
//  WeightBalance.swift
//  ClearedToPlan
//
//  Weight and balance calculation models
//

import Foundation

struct WeightBalanceCalculation: Equatable {
    var items: [WeightItem]
    var emptyWeight: Double
    var emptyArm: Double
    var envelope: [EnvelopePoint]

    var totalWeight: Double {
        emptyWeight + items.reduce(0) { $0 + $1.weight }
    }

    var totalMoment: Double {
        let emptyMoment = emptyWeight * emptyArm
        let loadedMoment = items.reduce(0) { $0 + ($1.weight * $1.arm) }
        return emptyMoment + loadedMoment
    }

    var centerOfGravity: Double {
        guard totalWeight > 0 else { return 0 }
        return totalMoment / totalWeight
    }

    var isWithinLimits: Bool {
        guard !envelope.isEmpty else { return true }
        return isPointInEnvelope(weight: totalWeight, cg: centerOfGravity)
    }

    private func isPointInEnvelope(weight: Double, cg: Double) -> Bool {
        guard envelope.count >= 3 else { return false }

        // Ray casting algorithm for point in polygon
        var inside = false
        var j = envelope.count - 1

        for i in 0..<envelope.count {
            let xi = envelope[i].cgIn
            let yi = envelope[i].weightLb
            let xj = envelope[j].cgIn
            let yj = envelope[j].weightLb

            if ((yi > weight) != (yj > weight)) &&
               (cg < (xj - xi) * (weight - yi) / (yj - yi) + xi) {
                inside.toggle()
            }
            j = i
        }

        return inside
    }
}

struct WeightItem: Identifiable, Equatable {
    let id: UUID
    var stationName: String
    var weight: Double
    var arm: Double

    init(
        id: UUID = UUID(),
        stationName: String = "",
        weight: Double = 0,
        arm: Double = 0
    ) {
        self.id = id
        self.stationName = stationName
        self.weight = weight
        self.arm = arm
    }
}
