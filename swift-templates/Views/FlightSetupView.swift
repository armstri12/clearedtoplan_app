//
//  FlightSetupView.swift
//  ClearedToPlan
//
//  Combined route and aircraft selection screen
//

import SwiftUI

struct FlightSetupView: View {
    @EnvironmentObject var flightSession: FlightSessionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var departure: String = ""
    @State private var destination: String = ""
    @State private var flightDate = Date()
    @State private var selectedAircraftId: UUID?
    @State private var aircraft: [Aircraft] = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Route") {
                    TextField("From (ICAO)", text: $departure)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()

                    TextField("To (ICAO)", text: $destination)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()

                    DatePicker("Date", selection: $flightDate, displayedComponents: .date)
                }

                Section("Aircraft") {
                    if aircraft.isEmpty {
                        ContentUnavailableView(
                            "No Aircraft",
                            systemImage: "airplane",
                            description: Text("Add an aircraft to continue")
                        )
                    } else {
                        ForEach(aircraft) { aircraft in
                            AircraftSelectionRow(
                                aircraft: aircraft,
                                isSelected: selectedAircraftId == aircraft.id
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedAircraftId = aircraft.id
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Flight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if flightSession.settings.planningMode == .advanced {
                        Button("Skip") {
                            dismiss()
                        }
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Start Planning") {
                        startPlanning()
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                loadData()
            }
        }
    }

    private var isValid: Bool {
        !departure.isEmpty &&
        !destination.isEmpty &&
        selectedAircraftId != nil
    }

    private func loadData() {
        // Load existing session data if any
        departure = flightSession.session.departureAirport ?? ""
        destination = flightSession.session.destinationAirport ?? ""
        flightDate = flightSession.session.flightDate
        selectedAircraftId = flightSession.session.selectedAircraftId

        // Load aircraft list
        aircraft = StorageService.shared.loadAircraft()
    }

    private func startPlanning() {
        guard let aircraftId = selectedAircraftId else { return }

        flightSession.updateFlightSetup(
            departure: departure,
            destination: destination,
            aircraftId: aircraftId,
            date: flightDate
        )

        dismiss()
    }
}

struct AircraftSelectionRow: View {
    let aircraft: Aircraft
    let isSelected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(aircraft.name)
                    .font(.headline)

                Text(aircraft.registration)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(aircraft.type)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.blue)
                    .font(.title3)
            } else {
                Image(systemName: "circle")
                    .foregroundStyle(.secondary)
                    .font(.title3)
            }
        }
    }
}

#Preview {
    FlightSetupView()
        .environmentObject(FlightSessionViewModel())
}
