//
//  ClearedToPlanApp.swift
//  ClearedToPlan
//
//  Main application entry point
//

import SwiftUI

@main
struct ClearedToPlanApp: App {
    @StateObject private var flightSession = FlightSessionViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(flightSession)
        }
    }
}
