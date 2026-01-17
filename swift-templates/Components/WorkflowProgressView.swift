//
//  WorkflowProgressView.swift
//  ClearedToPlan
//
//  Visual progress indicator for flight planning workflow
//

import SwiftUI

struct WorkflowProgressView: View {
    @EnvironmentObject var flightSession: FlightSessionViewModel

    var body: some View {
        VStack(spacing: 12) {
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 16)

                    // Progress
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue)
                        .frame(
                            width: geometry.size.width * (flightSession.session.progressPercentage / 100),
                            height: 16
                        )
                }
            }
            .frame(height: 16)

            // Progress Text
            HStack {
                Text("\(Int(flightSession.session.progressPercentage))% Complete")
                    .font(.caption)
                    .fontWeight(.medium)

                Spacer()

                Text("\(flightSession.session.completedSteps.count) of \(PlanningStep.allCases.count) steps")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Step Indicators
            HStack(spacing: 0) {
                ForEach(Array(PlanningStep.allCases.enumerated()), id: \.element) { index, step in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(stepColor(for: step))
                            .frame(width: 12, height: 12)
                            .overlay(
                                Circle()
                                    .stroke(Color(.systemBackground), lineWidth: 2)
                            )

                        Text(step.title)
                            .font(.system(size: 9))
                            .multilineTextAlignment(.center)
                            .frame(width: 60)
                    }

                    if index < PlanningStep.allCases.count - 1 {
                        Rectangle()
                            .fill(Color(.systemGray4))
                            .frame(height: 2)
                            .offset(y: -10)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func stepColor(for step: PlanningStep) -> Color {
        if flightSession.isStepCompleted(step) {
            return .green
        } else if flightSession.canAccessStep(step) {
            return .blue
        } else {
            return Color(.systemGray3)
        }
    }
}

#Preview {
    WorkflowProgressView()
        .environmentObject(FlightSessionViewModel())
        .padding()
}
