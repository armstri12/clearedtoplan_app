//
//  HomeView.swift
//  ClearedToPlan
//
//  Home screen with workflow progress
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var flightSession: FlightSessionViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "airplane.departure")
                            .font(.system(size: 60))
                            .foregroundStyle(.blue)

                        Text("Cleared to Plan")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("VFR Flight Planning")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 32)

                    // Workflow Progress
                    WorkflowProgressView()
                        .padding(.horizontal)

                    // Quick Actions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Flight Planning Steps")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)

                        ForEach(PlanningStep.allCases, id: \.self) { step in
                            StepCard(step: step)
                        }
                    }

                    // New Flight Button
                    if flightSession.session.progressPercentage == 100 {
                        Button {
                            flightSession.startNewFlight()
                        } label: {
                            Label("Start New Flight", systemImage: "plus.circle.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 32)
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct StepCard: View {
    @EnvironmentObject var flightSession: FlightSessionViewModel
    let step: PlanningStep

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: step.iconName)
                .font(.title2)
                .foregroundStyle(isCompleted ? .green : .blue)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(.headline)

                Text(statusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.title3)
            } else if !canAccess {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.secondary)
                    .font(.title3)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .opacity(canAccess ? 1.0 : 0.5)
    }

    private var isCompleted: Bool {
        flightSession.isStepCompleted(step)
    }

    private var canAccess: Bool {
        flightSession.canAccessStep(step)
    }

    private var statusText: String {
        if isCompleted {
            return "Completed"
        } else if canAccess {
            return "Ready to complete"
        } else {
            return "Complete previous steps first"
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(FlightSessionViewModel())
}
