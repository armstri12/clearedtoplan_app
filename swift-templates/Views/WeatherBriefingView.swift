//
//  WeatherBriefingView.swift
//  ClearedToPlan
//
//  Weather briefing with METAR/TAF (always accessible)
//

import SwiftUI

struct WeatherBriefingView: View {
    @EnvironmentObject var flightSession: FlightSessionViewModel
    @State private var stationId: String = ""
    @State private var isLoading = false
    @State private var weatherData: String?
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Quick airport buttons if flight setup complete
                    if flightSession.session.phase1Complete {
                        quickAirportButtons
                    }

                    // Station Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Station Identifier")
                            .font(.headline)

                        HStack {
                            TextField("ICAO (e.g., KPDX)", text: $stationId)
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

                            Text("Last updated: \(Date(), style: .time)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let error = errorMessage {
                        Text(error)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }
                }
                .padding()
            }
            .navigationTitle("Weather")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                // Auto-populate departure airport if available
                if let departure = flightSession.session.departureAirport,
                   stationId.isEmpty {
                    stationId = departure
                    fetchWeather()
                }
            }
        }
    }

    // Quick buttons for departure and destination
    private var quickAirportButtons: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Flight")
                .font(.headline)

            HStack(spacing: 12) {
                if let departure = flightSession.session.departureAirport {
                    Button {
                        stationId = departure
                        fetchWeather()
                    } label: {
                        VStack {
                            Text("Departure")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(departure)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                if let destination = flightSession.session.destinationAirport {
                    Button {
                        stationId = destination
                        fetchWeather()
                    } label: {
                        VStack {
                            Text("Destination")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(destination)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
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
