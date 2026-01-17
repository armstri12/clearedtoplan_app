//
//  WeatherBriefingView.swift
//  ClearedToPlan
//
//  Weather briefing with METAR/TAF
//

import SwiftUI

struct WeatherBriefingView: View {
    @EnvironmentObject var flightSession: FlightSessionViewModel

    var body: some View {
        NavigationStack {
            if flightSession.canAccessStep(.weather) {
                WeatherBriefingContentView()
            } else {
                WorkflowGuardView(step: .weather)
            }
        }
    }
}

struct WeatherBriefingContentView: View {
    @EnvironmentObject var flightSession: FlightSessionViewModel
    @State private var stationId: String = ""
    @State private var isLoading = false
    @State private var weatherData: String?
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Weather Briefing")
                    .font(.title2)
                    .fontWeight(.bold)

                // Station Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Station Identifier")
                        .font(.headline)

                    HStack {
                        TextField("ICAO (e.g., KXXX)", text: $stationId)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        Button {
                            fetchWeather()
                        } label: {
                            if isLoading {
                                ProgressView()
                            } else {
                                Image(systemName: "arrow.down.circle.fill")
                            }
                        }
                        .font(.title2)
                        .disabled(stationId.isEmpty || isLoading)
                    }
                }

                // Weather Display
                if let weather = weatherData {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("METAR")
                            .font(.headline)

                        Text(weather)
                            .font(.system(.body, design: .monospaced))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                if let error = errorMessage {
                    Text(error)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }

                if weatherData != nil {
                    Button("Mark Complete") {
                        flightSession.completeStep(.weather)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
        .navigationTitle("Weather")
    }

    private func fetchWeather() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                // Placeholder - implement actual weather service
                try await Task.sleep(nanoseconds: 1_000_000_000)
                weatherData = "METAR \(stationId.uppercased()) 171853Z 09014KT 10SM FEW050 SCT250 23/14 A3012 RMK AO2 SLP201"
            } catch {
                errorMessage = "Failed to fetch weather: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
}

#Preview {
    WeatherBriefingView()
        .environmentObject(FlightSessionViewModel())
}
