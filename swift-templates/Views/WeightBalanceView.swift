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
    @State private var stationWeights: [UUID: Double] = [:]
    @State private var fuelGallons: Double = 0

    private var selectedAircraft: Aircraft? {
        flightSession.selectedAircraft
    }

    private var calculation: WeightBalanceCalculation? {
        guard let aircraft = selectedAircraft else { return nil }

        var items: [WeightItem] = []

        // Add station weights
        for station in aircraft.stations {
            if let weight = stationWeights[station.id], weight > 0 {
                items.append(WeightItem(
                    stationName: station.name,
                    weight: weight,
                    arm: station.armIn
                ))
            }
        }

        // Add fuel
        if fuelGallons > 0 {
            let fuelWeight = fuelGallons * aircraft.fuelDensityLbPerGal
            // Assume fuel is at a standard arm (this should come from aircraft data ideally)
            // For now, use average of all station arms or a default
            let fuelArm = aircraft.stations.isEmpty ? 0 : aircraft.stations.map(\.armIn).reduce(0, +) / Double(aircraft.stations.count)
            items.append(WeightItem(
                stationName: "Fuel",
                weight: fuelWeight,
                arm: fuelArm
            ))
        }

        return WeightBalanceCalculation(
            items: items,
            emptyWeight: aircraft.emptyWeight,
            emptyArm: aircraft.emptyArm,
            envelope: aircraft.normalEnvelope
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let aircraft = selectedAircraft, let calc = calculation {
                    // Results Summary
                    ResultsSummaryCard(aircraft: aircraft, calculation: calc)

                    // Graphical Envelope Display
                    if !aircraft.normalEnvelope.isEmpty {
                        EnvelopeGraphView(aircraft: aircraft, calculation: calc)
                            .frame(height: 300)
                            .padding(.horizontal)
                    }

                    // Station Inputs
                    StationInputsSection(
                        aircraft: aircraft,
                        stationWeights: $stationWeights,
                        fuelGallons: $fuelGallons
                    )

                    // Detailed Breakdown
                    DetailedBreakdownSection(aircraft: aircraft, calculation: calc, fuelGallons: fuelGallons)

                } else {
                    // No aircraft selected
                    VStack(spacing: 16) {
                        Image(systemName: "airplane.circle")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)

                        Text("No Aircraft Selected")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text("Select an aircraft in Flight Setup to calculate weight & balance")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("W&B")
    }
}

// MARK: - Results Summary Card

struct ResultsSummaryCard: View {
    let aircraft: Aircraft
    let calculation: WeightBalanceCalculation

    var body: some View {
        VStack(spacing: 16) {
            // Status Badge
            HStack {
                Spacer()
                HStack(spacing: 8) {
                    Image(systemName: calculation.isWithinLimits ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    Text(calculation.isWithinLimits ? "Within Limits" : "OUT OF LIMITS")
                        .fontWeight(.semibold)
                }
                .foregroundStyle(calculation.isWithinLimits ? .green : .red)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(calculation.isWithinLimits ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                )
                Spacer()
            }

            // Key Metrics
            HStack(spacing: 32) {
                MetricView(
                    title: "Total Weight",
                    value: String(format: "%.1f", calculation.totalWeight),
                    unit: "lbs"
                )

                MetricView(
                    title: "CG Position",
                    value: String(format: "%.2f", calculation.centerOfGravity),
                    unit: "in"
                )

                MetricView(
                    title: "Total Moment",
                    value: String(format: "%.0f", calculation.totalMoment),
                    unit: "lb-in"
                )
            }

            // Weight Limits Check
            if let maxTakeoff = aircraft.maxTakeoffWeight {
                VStack(spacing: 4) {
                    HStack {
                        Text("Max Takeoff Weight:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int(maxTakeoff)) lbs")
                            .font(.caption)
                            .fontWeight(.medium)
                    }

                    ProgressView(value: min(calculation.totalWeight / maxTakeoff, 1.0))
                        .tint(calculation.totalWeight > maxTakeoff ? .red : .green)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5)
        )
        .padding(.horizontal)
    }
}

struct MetricView: View {
    let title: String
    let value: String
    let unit: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Envelope Graph View

struct EnvelopeGraphView: View {
    let aircraft: Aircraft
    let calculation: WeightBalanceCalculation

    var body: some View {
        GeometryReader { geometry in
            let envelope = aircraft.normalEnvelope
            guard !envelope.isEmpty else {
                return AnyView(EmptyView())
            }

            // Calculate bounds
            let minCG = envelope.map(\.cgIn).min() ?? 0
            let maxCG = envelope.map(\.cgIn).max() ?? 100
            let minWeight = envelope.map(\.weightLb).min() ?? 0
            let maxWeight = envelope.map(\.weightLb).max() ?? 3000

            let cgRange = maxCG - minCG
            let weightRange = maxWeight - minWeight

            // Add padding to the ranges
            let cgPadding = cgRange * 0.1
            let weightPadding = weightRange * 0.1

            let plotMinCG = minCG - cgPadding
            let plotMaxCG = maxCG + cgPadding
            let plotMinWeight = minWeight - weightPadding
            let plotMaxWeight = maxWeight + weightPadding

            let plotCGRange = plotMaxCG - plotMinCG
            let plotWeightRange = plotMaxWeight - plotMinWeight

            // Coordinate conversion functions
            func xPosition(for cg: Double) -> CGFloat {
                let normalized = (cg - plotMinCG) / plotCGRange
                return CGFloat(normalized) * geometry.size.width
            }

            func yPosition(for weight: Double) -> CGFloat {
                let normalized = (weight - plotMinWeight) / plotWeightRange
                return geometry.size.height - (CGFloat(normalized) * geometry.size.height)
            }

            return AnyView(
                ZStack {
                    // Background
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))

                    // Grid lines
                    Path { path in
                        // Vertical grid lines (CG)
                        for i in 0...5 {
                            let cg = plotMinCG + (plotCGRange * Double(i) / 5.0)
                            let x = xPosition(for: cg)
                            path.move(to: CGPoint(x: x, y: 0))
                            path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                        }

                        // Horizontal grid lines (Weight)
                        for i in 0...5 {
                            let weight = plotMinWeight + (plotWeightRange * Double(i) / 5.0)
                            let y = yPosition(for: weight)
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                        }
                    }
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)

                    // Envelope polygon
                    Path { path in
                        guard let first = envelope.first else { return }
                        path.move(to: CGPoint(
                            x: xPosition(for: first.cgIn),
                            y: yPosition(for: first.weightLb)
                        ))

                        for point in envelope.dropFirst() {
                            path.addLine(to: CGPoint(
                                x: xPosition(for: point.cgIn),
                                y: yPosition(for: point.weightLb)
                            ))
                        }

                        path.closeSubpath()
                    }
                    .fill(Color.green.opacity(0.2))
                    .overlay(
                        Path { path in
                            guard let first = envelope.first else { return }
                            path.move(to: CGPoint(
                                x: xPosition(for: first.cgIn),
                                y: yPosition(for: first.weightLb)
                            ))

                            for point in envelope.dropFirst() {
                                path.addLine(to: CGPoint(
                                    x: xPosition(for: point.cgIn),
                                    y: yPosition(for: point.weightLb)
                                ))
                            }

                            path.closeSubpath()
                        }
                        .stroke(Color.green, lineWidth: 2)
                    )

                    // Current CG point
                    Circle()
                        .fill(calculation.isWithinLimits ? Color.blue : Color.red)
                        .frame(width: 12, height: 12)
                        .position(
                            x: xPosition(for: calculation.centerOfGravity),
                            y: yPosition(for: calculation.totalWeight)
                        )

                    // Empty CG point
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .position(
                            x: xPosition(for: aircraft.emptyArm),
                            y: yPosition(for: aircraft.emptyWeight)
                        )

                    // Axis labels
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("CG (inches)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.bottom, 4)
                    }

                    HStack {
                        VStack {
                            Spacer()
                            Text("Weight (lbs)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .rotationEffect(.degrees(-90))
                            Spacer()
                        }
                        .padding(.leading, 4)
                        Spacer()
                    }

                    // Legend
                    VStack {
                        HStack(spacing: 16) {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 8, height: 8)
                                Text("Empty")
                                    .font(.caption2)
                            }

                            HStack(spacing: 4) {
                                Circle()
                                    .fill(calculation.isWithinLimits ? Color.blue : Color.red)
                                    .frame(width: 8, height: 8)
                                Text("Loaded")
                                    .font(.caption2)
                            }

                            Spacer()
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemBackground).opacity(0.9))
                        )
                        .padding(8)

                        Spacer()
                    }
                }
            )
        }
    }
}

// MARK: - Station Inputs Section

struct StationInputsSection: View {
    let aircraft: Aircraft
    @Binding var stationWeights: [UUID: Double]
    @Binding var fuelGallons: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Loading")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 0) {
                // Stations
                ForEach(aircraft.stations) { station in
                    VStack(spacing: 0) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(station.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("Arm: \(String(format: "%.1f", station.armIn))\"")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            TextField("0", value: Binding(
                                get: { stationWeights[station.id] ?? 0 },
                                set: { stationWeights[station.id] = $0 }
                            ), format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)

                            Text("lbs")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 30)
                        }
                        .padding()
                        .background(Color(.systemBackground))

                        Divider()
                    }
                }

                // Fuel
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Fuel")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("Max: \(String(format: "%.1f", aircraft.usableFuelGallons)) gal")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        TextField("0", value: $fuelGallons, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)

                        Text("gal")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 30)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            .padding(.horizontal)
        }
    }
}

// MARK: - Detailed Breakdown Section

struct DetailedBreakdownSection: View {
    let aircraft: Aircraft
    let calculation: WeightBalanceCalculation
    let fuelGallons: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Detailed Breakdown")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 0) {
                // Empty aircraft
                BreakdownRow(
                    name: "Empty Aircraft",
                    weight: aircraft.emptyWeight,
                    arm: aircraft.emptyArm,
                    moment: aircraft.emptyMoment,
                    isHeader: true
                )

                Divider()

                // Each item
                ForEach(calculation.items) { item in
                    BreakdownRow(
                        name: item.stationName,
                        weight: item.weight,
                        arm: item.arm,
                        moment: item.weight * item.arm
                    )
                    Divider()
                }

                // Total
                BreakdownRow(
                    name: "TOTAL",
                    weight: calculation.totalWeight,
                    arm: calculation.centerOfGravity,
                    moment: calculation.totalMoment,
                    isTotal: true
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            .padding(.horizontal)
        }
    }
}

struct BreakdownRow: View {
    let name: String
    let weight: Double
    let arm: Double
    let moment: Double
    var isHeader: Bool = false
    var isTotal: Bool = false

    var body: some View {
        HStack(spacing: 8) {
            Text(name)
                .font(isTotal ? .subheadline.bold() : .subheadline)
                .foregroundStyle(isHeader ? .secondary : .primary)
                .frame(width: 100, alignment: .leading)

            Spacer()

            Text(String(format: "%.1f", weight))
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 60, alignment: .trailing)

            Text("×")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(String(format: "%.2f", arm))
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 50, alignment: .trailing)

            Text("=")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(String(format: "%.0f", moment))
                .font(.caption)
                .fontWeight(isTotal ? .bold : .regular)
                .frame(width: 70, alignment: .trailing)
        }
        .padding()
        .background(isTotal ? Color(.systemGray5) : Color(.systemBackground))
    }
}

// MARK: - Workflow Guard View

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
