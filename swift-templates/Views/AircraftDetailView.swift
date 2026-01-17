//
//  AircraftDetailView.swift
//  ClearedToPlan
//
//  Comprehensive aircraft profile editor
//

import SwiftUI

struct AircraftDetailView: View {
    let aircraft: Aircraft?
    let onSave: (Aircraft) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var editedAircraft: Aircraft
    @State private var selectedTab = 0

    init(aircraft: Aircraft?, onSave: @escaping (Aircraft) -> Void) {
        self.aircraft = aircraft
        self.onSave = onSave
        _editedAircraft = State(initialValue: aircraft ?? Aircraft())
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                BasicInfoTab(aircraft: $editedAircraft)
                    .tabItem { Label("Basic", systemImage: "info.circle") }
                    .tag(0)

                WeightBalanceTab(aircraft: $editedAircraft)
                    .tabItem { Label("W&B", systemImage: "scalemass") }
                    .tag(1)

                StationsTab(aircraft: $editedAircraft)
                    .tabItem { Label("Stations", systemImage: "list.bullet") }
                    .tag(2)

                EnvelopeTab(aircraft: $editedAircraft)
                    .tabItem { Label("Envelope", systemImage: "chart.xyaxis.line") }
                    .tag(3)

                PerformanceTab(aircraft: $editedAircraft)
                    .tabItem { Label("Performance", systemImage: "gauge") }
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .navigationTitle(aircraft == nil ? "New Aircraft" : "Edit Aircraft")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAircraft()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    private var isValid: Bool {
        !editedAircraft.name.isEmpty &&
        !editedAircraft.registration.isEmpty
    }

    private func saveAircraft() {
        editedAircraft.updatedAt = Date()
        onSave(editedAircraft)
        dismiss()
    }
}

// MARK: - Basic Info Tab

struct BasicInfoTab: View {
    @Binding var aircraft: Aircraft

    var body: some View {
        Form {
            Section("Aircraft Information") {
                TextField("Name/Make & Model", text: $aircraft.name)
                    .textContentType(.name)

                TextField("Registration (N-Number)", text: $aircraft.registration)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()

                TextField("Type (e.g., C-172S)", text: $aircraft.type)

                TextField("Notes (optional)", text: Binding(
                    get: { aircraft.notes ?? "" },
                    set: { aircraft.notes = $0.isEmpty ? nil : $0 }
                ), axis: .vertical)
                .lineLimit(3...6)
            }
        }
    }
}

// MARK: - Weight & Balance Tab

struct WeightBalanceTab: View {
    @Binding var aircraft: Aircraft

    var body: some View {
        Form {
            Section("Empty Weight & Balance") {
                HStack {
                    Text("Empty Weight")
                    Spacer()
                    TextField("0", value: $aircraft.emptyWeight, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    Text("lbs")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Empty Moment")
                    Spacer()
                    TextField("0", value: $aircraft.emptyMoment, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    Text("lb-in")
                        .foregroundStyle(.secondary)
                }

                if aircraft.emptyWeight > 0 {
                    HStack {
                        Text("Empty Arm")
                        Spacer()
                        Text(String(format: "%.2f in", aircraft.emptyArm))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Weight Limits") {
                HStack {
                    Text("Max Ramp")
                    Spacer()
                    TextField("Optional", value: $aircraft.maxRampWeight, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    Text("lbs")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Max Takeoff")
                    Spacer()
                    TextField("Optional", value: $aircraft.maxTakeoffWeight, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    Text("lbs")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Max Landing")
                    Spacer()
                    TextField("Optional", value: $aircraft.maxLandingWeight, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    Text("lbs")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Fuel") {
                HStack {
                    Text("Usable Fuel")
                    Spacer()
                    TextField("0", value: $aircraft.usableFuelGallons, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    Text("gal")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Fuel Density")
                    Spacer()
                    TextField("6.0", value: $aircraft.fuelDensityLbPerGal, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    Text("lb/gal")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Stations Tab

struct StationsTab: View {
    @Binding var aircraft: Aircraft
    @State private var showingAddStation = false

    var body: some View {
        List {
            Section {
                ForEach($aircraft.stations) { $station in
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Station Name", text: $station.name)
                            .font(.headline)

                        HStack {
                            Text("Arm:")
                            TextField("0", value: $station.armIn, format: .number)
                                .keyboardType(.decimalPad)
                                .frame(width: 80)
                            Text("in")

                            Spacer()

                            Text("Max:")
                            TextField("Optional", value: $station.maxWeightLb, format: .number)
                                .keyboardType(.decimalPad)
                                .frame(width: 80)
                            Text("lbs")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                }
                .onDelete { indexSet in
                    aircraft.stations.remove(atOffsets: indexSet)
                }
            } header: {
                HStack {
                    Text("Stations")
                    Spacer()
                    Button {
                        addStation()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            } footer: {
                Text("Define loading stations (pilot, passenger, baggage, etc.) with their arm distance from the datum")
            }
        }
    }

    private func addStation() {
        let newStation = Station(name: "New Station")
        aircraft.stations.append(newStation)
    }
}

// MARK: - Envelope Tab

struct EnvelopeTab: View {
    @Binding var aircraft: Aircraft
    @State private var showingAddNormalPoint = false
    @State private var showingAddUtilityPoint = false

    var body: some View {
        Form {
            Section {
                ForEach($aircraft.normalEnvelope.indices, id: \.self) { index in
                    HStack {
                        TextField("Weight", value: $aircraft.normalEnvelope[index].weightLb, format: .number)
                            .keyboardType(.decimalPad)
                        Text("lbs @")
                        TextField("CG", value: $aircraft.normalEnvelope[index].cgIn, format: .number)
                            .keyboardType(.decimalPad)
                        Text("in")
                    }
                }
                .onDelete { indexSet in
                    aircraft.normalEnvelope.remove(atOffsets: indexSet)
                }

                Button {
                    aircraft.normalEnvelope.append(EnvelopePoint())
                } label: {
                    Label("Add Point", systemImage: "plus.circle")
                }
            } header: {
                Text("Normal Category Envelope")
            } footer: {
                Text("Define CG envelope points for normal category operations")
            }

            Section {
                if aircraft.utilityEnvelope == nil {
                    Button("Add Utility Category") {
                        aircraft.utilityEnvelope = []
                    }
                } else if let utilityEnvelope = Binding($aircraft.utilityEnvelope) {
                    ForEach(utilityEnvelope.indices, id: \.self) { index in
                        HStack {
                            TextField("Weight", value: utilityEnvelope[index].weightLb, format: .number)
                                .keyboardType(.decimalPad)
                            Text("lbs @")
                            TextField("CG", value: utilityEnvelope[index].cgIn, format: .number)
                                .keyboardType(.decimalPad)
                            Text("in")
                        }
                    }
                    .onDelete { indexSet in
                        aircraft.utilityEnvelope?.remove(atOffsets: indexSet)
                    }

                    Button {
                        aircraft.utilityEnvelope?.append(EnvelopePoint())
                    } label: {
                        Label("Add Point", systemImage: "plus.circle")
                    }

                    Button("Remove Utility Category", role: .destructive) {
                        aircraft.utilityEnvelope = nil
                    }
                }
            } header: {
                Text("Utility Category Envelope (Optional)")
            }
        }
    }
}

// MARK: - Performance Tab

struct PerformanceTab: View {
    @Binding var aircraft: Aircraft

    var body: some View {
        Form {
            Section("Takeoff Performance") {
                HStack {
                    Text("Ground Roll")
                    Spacer()
                    TextField("Optional", value: $aircraft.performance.takeoffGroundRoll, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    Text("ft")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Over 50 ft")
                    Spacer()
                    TextField("Optional", value: $aircraft.performance.takeoffOver50ft, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    Text("ft")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Landing Performance") {
                HStack {
                    Text("Ground Roll")
                    Spacer()
                    TextField("Optional", value: $aircraft.performance.landingGroundRoll, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    Text("ft")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Over 50 ft")
                    Spacer()
                    TextField("Optional", value: $aircraft.performance.landingOver50ft, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    Text("ft")
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                ForEach($aircraft.performance.cruisePerformance) { $cruise in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("RPM:")
                            TextField("2400", value: $cruise.rpm, format: .number)
                                .keyboardType(.numberPad)
                                .frame(width: 70)

                            Spacer()

                            Text("Alt:")
                            TextField("5000", value: $cruise.altitudeFt, format: .number)
                                .keyboardType(.numberPad)
                                .frame(width: 70)
                            Text("ft")
                        }

                        HStack {
                            Text("TAS:")
                            TextField("120", value: $cruise.tasKt, format: .number)
                                .keyboardType(.numberPad)
                                .frame(width: 70)
                            Text("kt")

                            Spacer()

                            Text("Fuel:")
                            TextField("8.5", value: $cruise.fuelBurnGPH, format: .number)
                                .keyboardType(.decimalPad)
                                .frame(width: 70)
                            Text("GPH")
                        }
                    }
                    .font(.subheadline)
                }
                .onDelete { indexSet in
                    aircraft.performance.cruisePerformance.remove(atOffsets: indexSet)
                }

                Button {
                    aircraft.performance.cruisePerformance.append(CruisePerformance())
                } label: {
                    Label("Add Cruise Setting", systemImage: "plus.circle")
                }
            } header: {
                Text("Cruise Performance (Optional)")
            } footer: {
                Text("Add cruise performance data for different power settings")
            }
        }
    }
}

#Preview {
    AircraftDetailView(aircraft: nil) { _ in }
}
