//
//  Weather.swift
//  ClearedToPlan
//
//  Weather data models
//

import Foundation

struct WeatherReport: Codable, Identifiable {
    let id: UUID
    var station: String
    var metar: String
    var taf: String?
    var fetchedAt: Date

    init(
        id: UUID = UUID(),
        station: String = "",
        metar: String = "",
        taf: String? = nil,
        fetchedAt: Date = Date()
    ) {
        self.id = id
        self.station = station
        self.metar = metar
        self.taf = taf
        self.fetchedAt = fetchedAt
    }
}
