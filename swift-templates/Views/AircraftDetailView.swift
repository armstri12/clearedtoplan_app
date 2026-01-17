//
//  AircraftDetailView.swift
//  ClearedToPlan
//
//  Comprehensive aircraft profile editor with clear tab navigation
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
            VStack(spacing: 0) {
                // Tab Picker at Top
                Picker("Section", selection: $selectedTab) {
                    Text("Basic").tag(0)
                    Text("W&B").tag(1)
                    Text("Stations").tag(2)
                    Text("Envelope").tag(3)
                    Text("Perf").tag(4)
                }
                .pickerStyle(.segmented)
                .padding()

                // Tab Content
                TabView(selection: $selectedTab) {
                    BasicInfoTab(aircraft: $editedAircraft)
                        .tag(0)

                    WeightBalanceTab(aircraft: $editedAircraft)
                        .tag(1)

                    StationsTab(aircraft: $editedAircraft)
                        .tag(2)

                    EnvelopeTab(aircraft: $editedAircraft)
                        .tag(3)

                    PerformanceTab(aircraft: $editedAircraft)
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
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
        // Require basic info only
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
            Section {
                TextField("Required", text: $aircraft.name)
                    .textContentType(.name)
            } header: {
                HStack {
                    Text("Name/Make & Model")
                    Text("*").foregroundStyle(.red)
                }
            }

            Section {
                TextField("Required", text: $aircraft.registration)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
            } header: {
                HStack {
                    Text("Registration (N-Number)")
                    Text("*").foregroundStyle(.red)
                }
            }

            Section("Type (Optional)") {
                TextField("e.g., C-172S, PA-28-180", text: $aircraft.type)
            }

            Section("Notes (Optional)") {
                TextField("Any additional notes", text: Binding(
                    get: { aircraft.notes ?? "" },
                    set: { aircraft.notes = $0.isEmpty ? nil : $0 }
                ), axis: .vertical)
                .lineLimit(3...6)
            }

            Section {
                Text("Swipe left or tap 'W&B' above to add weight & balance data")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .scrollContentBackground(.visible)
        .scrollIndicators(.visible, axes: .vertical)
    }
}

// MARK: - Weight & Balance Tab

struct WeightBalanceTab: View {
    @Binding var aircraft: Aircraft

    var body: some View {
        Form {
            Section {
                Text("Enter your aircraft's empty weight and moment from the weight & balance form")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Empty Weight & Balance") {
                HStack {
                    Text("Empty Weight")
                    Spacer()
                    TextField("0", value: $aircraft.emptyWeight, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                    Text("lbs")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Empty Moment")
                    Spacer()
                    TextField("0", value: $aircraft.emptyMoment, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
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

            Section("Weight Limits (Optional)") {
                HStack {
                    Text("Max Ramp")
                    Spacer()
                    TextField("Optional", value: $aircraft.maxRampWeight, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                    Text("lbs")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Max Takeoff")
                    Spacer()
                    TextField("Optional", value: $aircraft.maxTakeoffWeight, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                    Text("lbs")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Max Landing")
                    Spacer()
                    TextField("Optional", value: $aircraft.maxLandingWeight, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
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
                        .frame(width: 100)
                    Text("gal")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Fuel Density")
                    Spacer()
                    TextField("6.0", value: $aircraft.fuelDensityLbPerGal, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
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

    var body: some View {
        List {
            Section {
                Text("Define loading stations like Pilot, Passenger, Baggage with their arm distances from the datum")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                ForEach($aircraft.stations) { $station in
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Station Name (e.g., Pilot)", text: $station.name)
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
                    .padding(.vertical, 4)
                }
                .onDelete { indexSet in
                    aircraft.stations.remove(atOffsets: indexSet)
                }

                Button {
                    addStation()
                } label: {
                    Label("Add Station", systemImage: "plus.circle.fill")
                        .foregroundStyle(.blue)
                }
            } header: {
                Text("Stations (Optional)")
            }
        }
        .scrollContentBackground(.visible)
        .scrollIndicators(.visible, axes: .vertical)
    }

    private func addStation() {
        let newStation = Station(name: "New Station")
        aircraft.stations.append(newStation)
    }
}

// MARK: - Envelope Tab

struct EnvelopeTab: View {
    @Binding var aircraft: Aircraft

    var body: some View {
        Form {
            Section {
                Text("Define the CG envelope from your POH. Add points starting from the forward limit and going clockwise around the envelope")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Normal Category Envelope (Optional)") {
                ForEach($aircraft.normalEnvelope.indices, id: \.self) { index in
                    HStack {
                        TextField("Weight", value: $aircraft.normalEnvelope[index].weightLb, format: .number)
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                        Text("lbs @")
                        TextField("CG", value: $aircraft.normalEnvelope[index].cgIn, format: .number)
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                        Text("in")
                    }
                }
                .onDelete { indexSet in
                    aircraft.normalEnvelope.remove(atOffsets: indexSet)
                }

                Button {
                    aircraft.normalEnvelope.append(EnvelopePoint())
                } label: {
                    Label("Add Envelope Point", systemImage: "plus.circle.fill")
                        .foregroundStyle(.blue)
                }
            }

            Section("Utility Category (Optional)") {
                if aircraft.utilityEnvelope == nil {
                    Button("Add Utility Category") {
                        aircraft.utilityEnvelope = []
                    }
                } else if let utilityEnvelope = Binding($aircraft.utilityEnvelope) {
                    ForEach(utilityEnvelope.indices, id: \.self) { index in
                        HStack {
                            TextField("Weight", value: utilityEnvelope[index].weightLb, format: .number)
                                .keyboardType(.decimalPad)
                                .frame(width: 80)
                            Text("lbs @")
                            TextField("CG", value: utilityEnvelope[index].cgIn, format: .number)
                                .keyboardType(.decimalPad)
                                .frame(width: 80)
                            Text("in")
                        }
                    }
                    .onDelete { indexSet in
                        aircraft.utilityEnvelope?.remove(atOffsets: indexSet)
                    }

                    Button {
                        aircraft.utilityEnvelope?.append(EnvelopePoint())
                    } label: {
                        Label("Add Point", systemImage: "plus.circle.fill")
                            .foregroundStyle(.blue)
                    }

                    Button("Remove Utility Category", role: .destructive) {
                        aircraft.utilityEnvelope = nil
                    }
                }
            }
        }
        .scrollContentBackground(.visible)
        .scrollIndicators(.visible, axes: .vertical)
    }
}

// MARK: - Performance Tab

struct PerformanceTab: View {
    @Binding var aircraft: Aircraft

    var body: some View {
        Form {
            Section {
                Text("Enter performance data from your POH. All fields are optional")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Takeoff Performance") {
                HStack {
                    Text("Ground Roll")
                    Spacer()
                    TextField("Optional", value: $aircraft.performance.takeoffGroundRoll, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                    Text("ft")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Over 50 ft")
                    Spacer()
                    TextField("Optional", value: $aircraft.performance.takeoffOver50ft, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
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
                        .frame(width: 100)
                    Text("ft")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Over 50 ft")
                    Spacer()
                    TextField("Optional", value: $aircraft.performance.landingOver50ft, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                    Text("ft")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Cruise Performance (Optional)") {
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
                    Label("Add Cruise Setting", systemImage: "plus.circle.fill")
                        .foregroundStyle(.blue)
                }
            }
        }
        .scrollContentBackground(.visible)
        .scrollIndicators(.visible, axes: .vertical)
    }
}

#Preview {
    AircraftDetailView(aircraft: nil) { _ in }
}
