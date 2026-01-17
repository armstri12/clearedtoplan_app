//
//  ContentView.swift
//  ClearedToPlan
//
//  Root view with tab-based navigation
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var flightSession: FlightSessionViewModel

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            AircraftListView()
                .tabItem {
                    Label("Aircraft", systemImage: "airplane")
                }

            WeightBalanceView()
                .tabItem {
                    Label("W&B", systemImage: "scalemass.fill")
                }
                .badge(flightSession.isStepCompleted(.weightBalance) ? "✓" : "")

            PerformanceView()
                .tabItem {
                    Label("Performance", systemImage: "gauge.medium")
                }
                .badge(flightSession.isStepCompleted(.performance) ? "✓" : "")

            WeatherBriefingView()
                .tabItem {
                    Label("Weather", systemImage: "cloud.sun.fill")
                }
                .badge(flightSession.isStepCompleted(.weather) ? "✓" : "")

            NavigationLogView()
                .tabItem {
                    Label("Nav Log", systemImage: "map.fill")
                }
                .badge(flightSession.isStepCompleted(.navLog) ? "✓" : "")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(FlightSessionViewModel())
}
