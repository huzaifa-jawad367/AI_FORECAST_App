//
//  TreeInfoView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 17/02/2025.
//

import SwiftUI

let speciesCoefficients: [String: (a: Double, b: Double, c: Double)] = [
    "Oak":    (a: 0.12, b: 2.45, c: 1.10),
    "Pine":   (a: 0.08, b: 2.30, c: 1.15),
    "Maple":  (a: 0.10, b: 2.40, c: 1.05),
    "Birch":  (a: 0.09, b: 2.35, c: 1.10),
    "Spruce": (a: 0.07, b: 2.50, c: 1.20),
    "Other":  (a: 0.10, b: 2.40, c: 1.10)  // Default for unspecified species
]


struct ScanResultView: View {
    let image: UIImage
    let height: Double
    let diameter: Double
    let timestamp: Date
    
    @State private var Bestimation: Double = 0.0
    
    @Binding var authState: AuthState
    
    @State private var selectedSpecies: String = "Other"
    let speciesOptions = ["Oak", "Pine", "Maple", "Birch", "Spruce", "Other"]
    
    // Toggle for alert
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            // Tree image preview
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
                .accessibilityLabel("Tree Image")
                .accessibilityHint("Preview of the scanned tree")
            
            // Measurements and info
            VStack(alignment: .leading, spacing: 15) {
                Text("Tree Measurements")
                    .font(.title2)
                    .fontWeight(.bold)
                    .accessibilityAddTraits(.isHeader)
                
                HStack {
                    Text("Height:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(String(format: "%.2f meters", height))
                }
                .padding(.horizontal)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Height: \(String(format: "%.2f", height)) meters")
                
                HStack {
                    Text("Diameter:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(String(format: "%.2f cm", diameter))
                }
                .padding(.horizontal)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Diameter: \(String(format: "%.2f", diameter)) centimeters")
                
                HStack {
                    Text("Scan Time:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(timestamp.formatted(date: .abbreviated, time: .shortened))
                }
                .padding(.horizontal)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Scan Time: \(timestamp.formatted(date: .abbreviated, time: .shortened))")
                
                HStack {
                    Text("Species:")
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    // Species dropdown
                    Picker("Species", selection: $selectedSpecies) {
                        ForEach(speciesOptions, id: \.self) { species in
                            Text(species)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.2)))
                    //                    .padding()
                }
                .padding(.horizontal)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Species: \(selectedSpecies)")
                .accessibilityHint("Double tap to choose a tree species")
                
                if selectedSpecies.isEmpty {
                    HStack {
                        Text("Biomass Estimation:")
                            .fontWeight(.semibold)
                        Spacer()
                        Text("NA")
                    }
                    .padding(.horizontal)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Biomass Estimation: Not available")
                    
                } else {
                    // Show the biomass estimation number/ entry
                    HStack {
                        Text("Biomass Estimation:")
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(Bestimation)")
                    }
                    .padding(.horizontal)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Biomass Estimation: \(Bestimation)")
                }
                
            }
            .padding()
            
            Button(action: {
                // If species is not selected, show alert
                if selectedSpecies.isEmpty {
                    showAlert = true
                } else {
                    
                }
            }) {
                Text("Save")
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(Color.blue)
                    .cornerRadius(20)
            }
            .accessibilityLabel("Save")
            .accessibilityHint("Tap to save this scan record after selecting a species")
            
            Spacer()
            
            // Navigation buttons at the bottom
            HStack(spacing: 30) {
                Button(action: {
                    // Navigation back to dashboard
                    authState = .Dashboard
                }) {
                    Text("Dashboard")
                        .foregroundColor(.white)
                        .padding()
                    //                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .accessibilityLabel("Dashboard")
                .accessibilityHint("Tap to return to the dashboard")
                
                Button(action: {
                    // If species is not selected, show alert
                    if selectedSpecies.isEmpty {
                        showAlert = true
                    } else {
                        // Show the biomass estimation number/ entry
                        
                    }
                }) {
                    Text("Continue Scan")
                        .foregroundColor(.white)
                        .padding()
                    //                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .accessibilityLabel("Continue Scan")
                .accessibilityHint("Tap to continue scanning")
            }
            .padding([.horizontal, .bottom])
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Navigation options: Dashboard and Continue Scan")
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Species Not Selected"),
                    message: Text("Please select the tree species before proceeding."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .navigationTitle("Scan Details")
        .onChange(of: selectedSpecies) { newSpecies, _ in
            Task {
                do {
                    Bestimation = try await calculateBiomass(for: newSpecies, diameter: diameter, height: height)
                } catch {
                    Bestimation = -1
                }
            }
            
        }
        .task {
            do {
                // calculate Biomass for the current instance
                Bestimation = try await calculateBiomass(for:selectedSpecies, diameter: diameter, height: height)
            } catch {
                print("Error calculating the biomass")
            }
        }
    }
    
    func calculateBiomass(for species: String, diameter: Double, height: Double) async throws -> Double {
        // Unwrap the coefficients, throwing an error if not found
        guard let coefficients = speciesCoefficients[species] else {
            print("Coefficients not found for species: \(species)")
            throw NSError(domain: "CalculateBiomassError", code: 1, userInfo: nil)
        }
        
        // Biomass calculation using Allometric Equation
        let biomass = coefficients.a * pow(diameter, coefficients.b) * pow(height, coefficients.c)
        print("Biomass: \(biomass)")
        
        return biomass
    }
    
    func SaveScanedRecordToDatabase() {
        
    }

}

// Example preview
struct ScanResultView_Previews: PreviewProvider {
    static var previews: some View {
        ScanResultView(
            image: UIImage(systemName: "leaf")!, // Placeholder image
            height: 12.5,
            diameter: 30.2,
            timestamp: Date(),
            authState: .constant(.ScanResultView)
        )
    }
}
