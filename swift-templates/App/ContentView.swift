//
//  ContentView.swift
//  ClearedToPlan
//
//  Root view with mode selection and dual tab structure
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var flightSession: FlightSessionViewModel
    @State private var showingWeather = false

    var body: some View {
        Group {
            if !flightSession.settings.hasCompletedOnboarding {
                // First launch: show mode selection
                ModeSelectionView()
            } else {
                // Main app with mode-specific tabs
                mainContent
            }
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        if flightSession.settings.planningMode == .guided {
            guidedModeTabs
        } else {
            advancedModeTabs
        }
    }

    // MARK: - Guided Mode (Locked tabs until setup complete)

    private var guidedModeTabs: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            WeightBalanceView()
                .tabItem {
                    Label("W&B", systemImage: "scalemass.fill")
                }
                .badge(flightSession.isStepCompleted(.weightBalance) ? "✓" : "")
                .disabled(!flightSession.canAccessStep(.weightBalance))

            PerformanceView()
                .tabItem {
                    Label("Performance", systemImage: "gauge.medium")
                }
                .badge(flightSession.isStepCompleted(.performance) ? "✓" : "")
                .disabled(!flightSession.canAccessStep(.performance))

            NavigationLogView()
                .tabItem {
                    Label("Nav Log", systemImage: "map.fill")
                }
                .badge(flightSession.isStepCompleted(.navLog) ? "✓" : "")
                .disabled(!flightSession.canAccessStep(.navLog))

            SettingsView()
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle.fill")
                }
        }
        .overlay(alignment: .topTrailing) {
            weatherButton
        }
    }

    // MARK: - Advanced Mode (All tabs unlocked)

    private var advancedModeTabs: some View {
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

            NavigationLogView()
                .tabItem {
                    Label("Nav Log", systemImage: "map.fill")
                }
                .badge(flightSession.isStepCompleted(.navLog) ? "✓" : "")

            SettingsView()
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle.fill")
                }
        }
        .overlay(alignment: .topTrailing) {
            weatherButton
        }
    }

    // MARK: - Weather Toolbar Button

    private var weatherButton: some View {
        Button {
            showingWeather = true
        } label: {
            Image(systemName: "cloud.sun.fill")
                .font(.title2)
                .foregroundStyle(.white)
                .padding(12)
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(radius: 4)
        }
        .padding()
        .sheet(isPresented: $showingWeather) {
            WeatherBriefingView()
        }
    }
}

// MARK: - Settings View (Placeholder)

struct SettingsView: View {
    @EnvironmentObject var flightSession: FlightSessionViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Planning Mode") {
                    Picker("Mode", selection: Binding(
                        get: { flightSession.settings.planningMode },
                        set: { flightSession.updatePlanningMode($0) }
                    )) {
                        Text("Guided").tag(PlanningMode.guided)
                        Text("Advanced").tag(PlanningMode.advanced)
                    }
                    .pickerStyle(.segmented)

                    Text(modeDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Flight Data") {
                    Button("New Flight") {
                        flightSession.startNewFlight()
                    }

                    Button("Clear Current Flight") {
                        flightSession.resetSession()
                    }

                    NavigationLink("Flight History") {
                        FlightHistoryView()
                    }
                }

                Section("Data Management") {
                    Button("Clear All Data", role: .destructive) {
                        StorageService.shared.clearAllData()
                        flightSession.resetSession()
                    }
                }

                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    private var modeDescription: String {
        if flightSession.settings.planningMode == .guided {
            return "Step-by-step workflow with locked tabs until setup complete"
        } else {
            return "All features unlocked for maximum flexibility"
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(FlightSessionViewModel())
}
