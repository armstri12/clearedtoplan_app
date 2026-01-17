//
//  WeightBalanceView.swift
//  ClearedToPlan
//
//  Weight and balance calculator
//

import SwiftUI

struct WeightBalanceView: View {
    @EnvironmentObject var flightSession: FlightSessionViewModel

    var body: some View {
        NavigationStack {
            if flightSession.canAccessStep(.weightBalance) {
                WeightBalanceCalculatorView()
            } else {
                WorkflowGuardView(step: .weightBalance)
            }
        }
    }
}

struct WeightBalanceCalculatorView: View {
    @EnvironmentObject var flightSession: FlightSessionViewModel
    @State private var items: [WeightItem] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Weight & Balance Calculator")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Coming Soon")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                // Placeholder for weight & balance form
                // Will include:
                // - Station weight inputs
                // - Real-time CG calculation
                // - Graphical envelope display

                Button("Mark Complete") {
                    flightSession.completeStep(.weightBalance)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("W&B")
    }
}

struct WorkflowGuardView: View {
    let step: PlanningStep

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("Step Locked")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Complete the previous steps before accessing \(step.title)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    WeightBalanceView()
        .environmentObject(FlightSessionViewModel())
}
