//
//  AircraftListView.swift
//  ClearedToPlan
//
//  List of saved aircraft profiles
//

import SwiftUI
import Combine

struct AircraftListView: View {
    @StateObject private var viewModel = AircraftViewModel()
    @EnvironmentObject var flightSession: FlightSessionViewModel
    @State private var showingAddAircraft = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.aircraft.isEmpty {
                    emptyStateView
                } else {
                    aircraftList
                }
            }
            .navigationTitle("Aircraft")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddAircraft = true
                    } label: {
                        Label("Add Aircraft", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddAircraft) {
                AircraftFormView(aircraft: nil) { newAircraft in
                    viewModel.addAircraft(newAircraft)
                    showingAddAircraft = false
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "airplane.circle")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)

            Text("No Aircraft Profiles")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Add your first aircraft to begin flight planning")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showingAddAircraft = true
            } label: {
                Label("Add Aircraft", systemImage: "plus")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
    }

    private var aircraftList: some View {
        List {
            ForEach(viewModel.aircraft) { aircraft in
                AircraftRow(
                    aircraft: aircraft,
                    isSelected: flightSession.session.selectedAircraftId == aircraft.id
                )
                .onTapGesture {
                    flightSession.selectAircraft(aircraft.id)
                    // Note: Aircraft selection is part of flight setup, not a separate step
                }
            }
            .onDelete { indexSet in
                indexSet.forEach { viewModel.deleteAircraft(at: $0) }
            }
        }
    }
}

struct AircraftRow: View {
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
                    .foregroundStyle(.green)
                    .font(.title3)
            }
        }
    }
}

struct AircraftFormView: View {
    let aircraft: Aircraft?
    let onSave: (Aircraft) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var registration = ""
    @State private var type = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Information") {
                    TextField("Name (e.g., Skyhawk)", text: $name)
                    TextField("Registration (e.g., N12345)", text: $registration)
                    TextField("Type (e.g., C-172S)", text: $type)
                }
            }
            .navigationTitle(aircraft == nil ? "Add Aircraft" : "Edit Aircraft")
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
                    .disabled(name.isEmpty || registration.isEmpty)
                }
            }
        }
        .onAppear {
            if let aircraft {
                name = aircraft.name
                registration = aircraft.registration
                type = aircraft.type
            }
        }
    }

    private func saveAircraft() {
        let newAircraft = Aircraft(
            name: name,
            registration: registration,
            type: type
        )
        onSave(newAircraft)
        dismiss()
    }
}

// Placeholder ViewModel
@MainActor
class AircraftViewModel: ObservableObject {
    @Published var aircraft: [Aircraft] = []

    init() {
        loadAircraft()
    }

    func loadAircraft() {
        aircraft = StorageService.shared.loadAircraft()
    }

    func addAircraft(_ aircraft: Aircraft) {
        self.aircraft.append(aircraft)
        saveAircraft()
    }

    func deleteAircraft(at index: Int) {
        let id = aircraft[index].id
        aircraft.remove(at: index)
        StorageService.shared.deleteAircraft(id: id)
        saveAircraft()
    }

    private func saveAircraft() {
        StorageService.shared.saveAircraft(aircraft)
    }
}

#Preview {
    AircraftListView()
        .environmentObject(FlightSessionViewModel())
}
