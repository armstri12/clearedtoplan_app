//
//  HomeView.swift
//  ClearedToPlan
//
//  Home dashboard with current flight and history
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var flightSession: FlightSessionViewModel
    @State private var showingFlightSetup = false
    @State private var showingResumeDialog = false
    @State private var recentFlights: [CompletedFlight] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Current Flight Card
                    if flightSession.session.phase1Complete {
                        currentFlightCard
                    } else {
                        emptyFlightCard
                    }

                    // Recent Flights
                    if !recentFlights.isEmpty {
                        recentFlightsSection
                    }

                    // Quick Actions
                    quickActionsSection
                }
                .padding()
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingFlightSetup = true
                    } label: {
                        Label("New Flight", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingFlightSetup) {
                FlightSetupView()
            }
            .onAppear {
                loadRecentFlights()
            }
        }
    }

    // MARK: - Current Flight

    private var currentFlightCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Current Flight")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button {
                    showingFlightSetup = true
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundStyle(.blue)
                }
            }

            // Route and Aircraft Info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "airplane.departure")
                        .foregroundStyle(.blue)
                    Text(flightSession.session.routeDescription)
                        .font(.title3)
                        .fontWeight(.semibold)
                }

                if let aircraftId = flightSession.session.selectedAircraftId,
                   let aircraft = loadAircraft(id: aircraftId) {
                    HStack {
                        Image(systemName: "airplane")
                            .foregroundStyle(.secondary)
                        Text("\(aircraft.name) (\(aircraft.registration))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(.secondary)
                    Text(flightSession.session.flightDate, style: .date)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            // Progress Checklist
            VStack(alignment: .leading, spacing: 12) {
                Text("Progress")
                    .font(.headline)

                ProgressRow(
                    title: "Flight Setup",
                    isComplete: flightSession.session.phase1Complete
                )

                ForEach([PlanningStep.weightBalance, .performance, .navLog], id: \.self) { step in
                    ProgressRow(
                        title: step.title,
                        isComplete: flightSession.isStepCompleted(step)
                    )
                }
            }

            // Action Buttons
            HStack(spacing: 12) {
                Button {
                    // Continue to next incomplete step
                } label: {
                    Label("Continue Planning", systemImage: "arrow.right.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    flightSession.startNewFlight()
                } label: {
                    Label("New Flight", systemImage: "plus.circle")
                        .font(.headline)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.3), lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var emptyFlightCard: some View {
        VStack(spacing: 20) {
            Image(systemName: "airplane.circle")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("No Active Flight")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Start planning your next flight")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                showingFlightSetup = true
            } label: {
                Label("New Flight", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Recent Flights

    private var recentFlightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Flights")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                NavigationLink("View All") {
                    FlightHistoryView()
                }
                .font(.subheadline)
            }

            ForEach(recentFlights.prefix(3)) { flight in
                RecentFlightRow(flight: flight) {
                    flightSession.loadFlightFromHistory(flight)
                }
            }
        }
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                QuickActionButton(
                    icon: "cloud.sun.fill",
                    title: "Weather",
                    color: .blue
                ) {
                    // Show weather
                }

                QuickActionButton(
                    icon: "airplane",
                    title: "Aircraft",
                    color: .orange
                ) {
                    // Show aircraft
                }
            }
        }
    }

    // MARK: - Helpers

    private func loadRecentFlights() {
        recentFlights = FlightHistoryService.shared.loadRecentFlights(limit: 3)
    }

    private func loadAircraft(id: UUID) -> Aircraft? {
        StorageService.shared.loadAircraft().first { $0.id == id }
    }
}

// MARK: - Supporting Views

struct ProgressRow: View {
    let title: String
    let isComplete: Bool

    var body: some View {
        HStack {
            Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isComplete ? .green : .secondary)

            Text(title)
                .font(.subheadline)
                .foregroundStyle(isComplete ? .primary : .secondary)

            Spacer()

            if !isComplete {
                Text("Not started")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct RecentFlightRow: View {
    let flight: CompletedFlight
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(flight.routeDescription)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text("\(flight.dateFormatted) · \(flight.aircraftName)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundStyle(color)

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// Placeholder for Flight History View
struct FlightHistoryView: View {
    @EnvironmentObject var flightSession: FlightSessionViewModel
    @State private var flights: [CompletedFlight] = []

    var body: some View {
        List {
            ForEach(flights) { flight in
                RecentFlightRow(flight: flight) {
                    flightSession.loadFlightFromHistory(flight)
                }
            }
        }
        .navigationTitle("Flight History")
        .onAppear {
            flights = FlightHistoryService.shared.loadAllFlights()
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(FlightSessionViewModel())
}
