//
//  ModeSelectionView.swift
//  ClearedToPlan
//
//  First-launch mode selection
//

import SwiftUI

struct ModeSelectionView: View {
    @EnvironmentObject var flightSession: FlightSessionViewModel

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Image(systemName: "airplane.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)

                Text("Welcome to Cleared to Plan")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Choose your planning style")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 16) {
                ModeCard(
                    icon: "list.bullet.clipboard.fill",
                    title: "Guided Mode",
                    description: "Step-by-step workflow\nEnsures complete planning",
                    color: .blue
                ) {
                    selectMode(.guided)
                }

                ModeCard(
                    icon: "bolt.fill",
                    title: "Advanced Mode",
                    description: "All features unlocked\nMaximum flexibility",
                    color: .orange
                ) {
                    selectMode(.advanced)
                }
            }
            .padding(.horizontal)

            Text("You can change this anytime in Settings")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private func selectMode(_ mode: PlanningMode) {
        flightSession.updatePlanningMode(mode)
        flightSession.completeOnboarding()
    }
}

struct ModeCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundStyle(color)
                    .frame(width: 60)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ModeSelectionView()
        .environmentObject(FlightSessionViewModel())
}
