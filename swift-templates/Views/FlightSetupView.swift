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
    @State private var showingAddAircraft = false

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

                Section {
                    if aircraft.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "airplane.circle")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)

                            Text("No Aircraft")
                                .font(.headline)

                            Text("Add your first aircraft to continue")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)

                            Button {
                                showingAddAircraft = true
                            } label: {
                                Label("Add Aircraft", systemImage: "plus.circle.fill")
                                    .font(.headline)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
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
                } header: {
                    HStack {
                        Text("Aircraft")
                        Spacer()
                        if !aircraft.isEmpty {
                            Button {
                                showingAddAircraft = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Flight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Start Planning") {
                        startPlanning()
                    }
                    .disabled(!isValid)
                }
            }
            .sheet(isPresented: $showingAddAircraft) {
                AircraftDetailView(aircraft: nil) { newAircraft in
                    addAircraft(newAircraft)
                    showingAddAircraft = false
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

    private func addAircraft(_ newAircraft: Aircraft) {
        // Save to storage
        var allAircraft = StorageService.shared.loadAircraft()
        allAircraft.append(newAircraft)
        StorageService.shared.saveAircraft(allAircraft)

        // Reload list and auto-select new aircraft
        aircraft = allAircraft
        selectedAircraftId = newAircraft.id
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
