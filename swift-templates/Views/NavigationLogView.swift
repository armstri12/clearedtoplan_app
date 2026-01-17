//
//  NavigationLogView.swift
//  ClearedToPlan
//
//  Navigation log builder
//

import SwiftUI

struct NavigationLogView: View {
    @EnvironmentObject var flightSession: FlightSessionViewModel

    var body: some View {
        NavigationStack {
            if flightSession.canAccessStep(.navLog) {
                NavigationLogBuilderView()
            } else {
                WorkflowGuardView(step: .navLog)
            }
        }
    }
}

struct NavigationLogBuilderView: View {
    @EnvironmentObject var flightSession: FlightSessionViewModel
    @State private var legs: [NavigationLeg] = []
    @State private var showingAddLeg = false

    var body: some View {
        VStack {
            if legs.isEmpty {
                emptyStateView
            } else {
                legsList
            }
        }
        .navigationTitle("Nav Log")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddLeg = true
                } label: {
                    Label("Add Leg", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddLeg) {
            NavigationLegFormView { newLeg in
                legs.append(newLeg)
                showingAddLeg = false
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "map.circle")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)

            Text("No Flight Legs")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Add flight legs to create your navigation log")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showingAddLeg = true
            } label: {
                Label("Add Leg", systemImage: "plus")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
    }

    private var legsList: some View {
        List {
            ForEach(legs) { leg in
                NavigationLegRow(leg: leg)
            }
            .onDelete { indexSet in
                legs.remove(atOffsets: indexSet)
            }

            Section {
                Button("Complete Nav Log") {
                    flightSession.completeStep(.navLog)
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

struct NavigationLegRow: View {
    let leg: NavigationLeg

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(leg.from) → \(leg.to)")
                    .font(.headline)
                Spacer()
                Text("\(Int(leg.distance)) nm")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                Label("\(leg.altitude) ft", systemImage: "arrow.up")
                Label("\(leg.course)°", systemImage: "location.north")
                if leg.groundSpeed > 0 {
                    Label("\(Int(leg.groundSpeed)) kts", systemImage: "speedometer")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
}

struct NavigationLegFormView: View {
    let onSave: (NavigationLeg) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var from = ""
    @State private var to = ""
    @State private var altitude = ""
    @State private var course = ""
    @State private var distance = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Waypoints") {
                    TextField("From (e.g., KXXX)", text: $from)
                        .textInputAutocapitalization(.characters)
                    TextField("To (e.g., KYYY)", text: $to)
                        .textInputAutocapitalization(.characters)
                }

                Section("Flight Data") {
                    TextField("Altitude (ft)", text: $altitude)
                        .keyboardType(.numberPad)
                    TextField("Course (°)", text: $course)
                        .keyboardType(.numberPad)
                    TextField("Distance (nm)", text: $distance)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Add Leg")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveLeg()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    private var isValid: Bool {
        !from.isEmpty && !to.isEmpty &&
        Int(altitude) != nil && Int(course) != nil &&
        Double(distance) != nil
    }

    private func saveLeg() {
        let leg = NavigationLeg(
            from: from.uppercased(),
            to: to.uppercased(),
            altitude: Int(altitude) ?? 0,
            course: Int(course) ?? 0,
            distance: Double(distance) ?? 0,
            windDirection: 0,
            windSpeed: 0,
            groundSpeed: 0,
            timeEnRoute: 0,
            fuelBurn: 0
        )
        onSave(leg)
        dismiss()
    }
}

#Preview {
    NavigationLogView()
        .environmentObject(FlightSessionViewModel())
}
