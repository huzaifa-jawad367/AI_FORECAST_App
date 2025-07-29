//
//  TreeInfoView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 17/02/2025.
//

import SwiftUI
import CoreLocation
import Combine

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}
#endif


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
    let timestamp: Date
    let projectId: String? // <-- Default value is nil
    
    @State private var Bestimation: Double = 0.0
    
    @Binding var authState: AuthState
    
    @State private var diameterInput: String = ""
    @State private var selectedSpecies: String = "Other"
    let speciesOptions = ["Oak", "Pine", "Maple", "Birch", "Spruce", "Other"]
    
    // Toggle for alert
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var projectViewModel = ProjectViewModel()
    @State private var selectedProjectId: String? = nil
    
    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var locationManager = LocationManager.shared

    init(
        image: UIImage,
        height: Double,
        timestamp: Date,
        projectId: String? = nil,
        authState: Binding<AuthState>
    ) {
        self.image = image
        self.height = height
        self.timestamp = timestamp
        self.projectId = projectId
        self._authState = authState
    }
    
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
                    Text("Diameter (cm):")
                        .fontWeight(.semibold)
                    Spacer()
                    TextField("Enter diameter", text: $diameterInput)
                      .keyboardType(.decimalPad)
                      .multilineTextAlignment(.trailing)
                      .frame(width: 100)
                      .padding(6)
                      .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.2)))
                      .onChange(of: diameterInput) {
                          // strip out any non-numeric/“.” chars
                          let filtered = diameterInput.filter { "0123456789.".contains($0) }
                          if filtered != diameterInput {
                              diameterInput = filtered
                          }
                          recalcBiomass()
                      }
                      .submitLabel(.done)               // shows “Done” on hardware keyboards
                      .onSubmit { hideKeyboard() }      // hides for hardware “Enter”
                      .toolbar {                        // adds “Done” above the decimal pad
                          ToolbarItemGroup(placement: .keyboard) {
                              Spacer()
                              Button("Done") {
                                  hideKeyboard()
                              }
                          }
                      }
                }
                .padding(.horizontal)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Diameter: \(String(format: "%.2f", diameterInput)) centimeters")
                
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
                
                // Project Picker if projectId is nil
                if projectId == nil {
                    HStack(alignment: .center) {
                        Text("Select Project:")
                            .fontWeight(.semibold)
                        Spacer()
                        Picker("Project", selection: $selectedProjectId) {
                            Text("Select a project").tag(String?.none)
                            ForEach(projectViewModel.projects) { project in
                                Text(project.project_name).tag(Optional(project.project_id))
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .onAppear {
                            if let user = sessionManager.user {
                                Task {
                                    await projectViewModel.fetchProjects(for: user.id.uuidString)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            
            
            Button(action: {
                // If species is not selected, show alert
                if selectedSpecies == "Other" {
                    alertMessage = "Please select the tree species before proceeding."
                    showAlert = true
                } else if projectId == nil && selectedProjectId == nil {
                    alertMessage = "Please select a project before saving."
                    showAlert = true
                } else {
                    Task {
                        guard let supabaseUser = sessionManager.user else {
                            viewModel.isSignedIn = false
                            return
                        }
                        print("user is signed in\n\n")
                        
                        do {
                            print("Step 0")
                            let profile = try await viewModel.fetchUserProfile(userID: supabaseUser.id.uuidString)
                            print("Step 1")
                            viewModel.currentUser = profile
                            print("Step 2")
                            viewModel.isSignedIn = true
                            print("Step 3: Is signed in: \(profile)")
                            
                            let diam = Double(diameterInput) ?? 0
                            let finalProjectId = projectId ?? selectedProjectId!
                            
                            SaveScanedRecordToDatabase(height: height, diameter: diam, species: selectedSpecies, project_id: finalProjectId, user_id: profile.id, biomass_estimation: Bestimation)
                            // SaveScanedRecordToDatabase(height: height, diameter: diam, species: selectedSpecies, project_id: "16089a3d-ca0d-4e73-ace4-ff4813bb9f0b", user_id: profile.id, biomass_estimation: Bestimation)
                        } catch {
                            print("Error fetch profile: \(error.localizedDescription)")
                            viewModel.isSignedIn = false
                        }
                         
                    }
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
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Missing Information"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            
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
                        authState = .scanPage
                        
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
        .contentShape(Rectangle())            // so empty space catches taps
        .onTapGesture { hideKeyboard() }
        .navigationTitle("Scan Details")
        .onChange(of: selectedSpecies) { newSpecies, _ in
            Task {
                do {
                    Bestimation = try await calculateBiomass(for: newSpecies, diameter: Double(diameterInput) ?? 0, height: height)
                } catch {
                    Bestimation = -1
                }
            }
            
        }
        .task {
            do {
                // calculate Biomass for the current instance
                Bestimation = try await calculateBiomass(for:selectedSpecies, diameter: Double(diameterInput) ?? 0, height: height)
            } catch {
                print("Error calculating the biomass")
            }
        }
    }
    
    private func getCurrentTimestamp() -> String {
        let now = Date()
        
        // Format the main data and time
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let baseString = formatter.string(from: now)
        
        // Extract the nanosecond component and convert to microsecond
        let calendar = Calendar.current
        let nanoseconds = calendar.component(.nanosecond, from: now)
        let microseconds = nanoseconds / 1000

        // Combine the formatted date string with the microseconds (6 digits)
        return String(format: "%@.%06d", baseString, microseconds)
    }
    
    private func recalcBiomass() {
        Task {
            let diam = Double(diameterInput) ?? 0
            do {
                Bestimation = try await calculateBiomass(
                    for: selectedSpecies,
                    diameter: diam,
                    height: height
                )
            } catch {
                Bestimation = -1
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
    
    private func SaveScanedRecordToDatabase(height: Double, diameter: Double, species: String, project_id: String, user_id: String, biomass_estimation: Double) {
        // Get the current timestamp.
        let scanTimestamp = getCurrentTimestamp()
        
        // pull coords from our shared manager
        let lat = Float(locationManager.currentLocation?.coordinate.latitude ?? 0)
        let lon = Float(locationManager.currentLocation?.coordinate.longitude ?? 0)
        
        // Create a ScanRecord_write instance using the current data.
        let scanRecord = ScanRecord_write(
            height: height,
            diameter: diameter,
            species: species,
            scan_time: scanTimestamp,
            project_id: project_id,
            user_id: user_id,
            biomass_estimation: biomass_estimation,
            latitude: lat,
            longitude: lon
        )
        
        print("The scan record instance I am adding: \(scanRecord)")
        
        // Perform the asynchronous database insertion.
        Task {
            do {
                try await client.database
                    .from("scans")  // Make sure this table name matches your schema
                    .insert(scanRecord)
                    .execute()
                print("Scan record saved successfully")
            } catch {
                print("Error saving scan record: \(error.localizedDescription)")
            }
        }
    }

}

// Example preview
struct ScanResultView_Previews: PreviewProvider {
    static var previews: some View {
        ScanResultView(
            image: UIImage(systemName: "leaf")!, // Placeholder image
            height: 12.5,
            timestamp: Date(),
            authState: .constant(.ScanResultView)
        )
        .environmentObject(SessionManager())
    }
}
