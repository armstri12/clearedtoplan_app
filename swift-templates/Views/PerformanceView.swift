//
//  PerformanceView.swift
//  ClearedToPlan
//
//  Performance calculator (density altitude, takeoff/landing)
//

import SwiftUI

struct PerformanceView: View {
    @EnvironmentObject var flightSession: FlightSessionViewModel

    var body: some View {
        NavigationStack {
            if flightSession.canAccessStep(.performance) {
                PerformanceCalculatorView()
            } else {
                WorkflowGuardView(step: .performance)
            }
        }
    }
}

struct PerformanceCalculatorView: View {
    @EnvironmentObject var flightSession: FlightSessionViewModel
    @State private var fieldElevation: String = ""
    @State private var temperature: String = ""
    @State private var altimeterSetting: String = "29.92"

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Performance Calculator")
                    .font(.title2)
                    .fontWeight(.bold)

                // Density Altitude Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Density Altitude")
                        .font(.headline)

                    VStack(spacing: 12) {
                        HStack {
                            Text("Field Elevation")
                            Spacer()
                            TextField("Feet", text: $fieldElevation)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                        }

                        HStack {
                            Text("Temperature")
                            Spacer()
                            TextField("°C", text: $temperature)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                        }

                        HStack {
                            Text("Altimeter")
                            Spacer()
                            TextField("inHg", text: $altimeterSetting)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    if let da = calculatedDensityAltitude {
                        HStack {
                            Text("Density Altitude:")
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(Int(da)) ft")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.blue)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                Text("Takeoff/landing distance calculations coming soon")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button("Mark Complete") {
                    flightSession.completeStep(.performance)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("Performance")
    }

    private var calculatedDensityAltitude: Double? {
        guard let elevation = Double(fieldElevation),
              let temp = Double(temperature),
              let altimeter = Double(altimeterSetting) else {
            return nil
        }

        let pa = CalculationService.pressureAltitude(
            fieldElevation: elevation,
            altimeterSetting: altimeter
        )

        return CalculationService.densityAltitude(
            pressureAltitude: pa,
            temperature: temp
        )
    }
}

#Preview {
    PerformanceView()
        .environmentObject(FlightSessionViewModel())
}
