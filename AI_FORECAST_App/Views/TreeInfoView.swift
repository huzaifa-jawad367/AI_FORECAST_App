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

// TODO: Extract subviews/project picker/etc. into smaller components to improve compile times and maintainability
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
    
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var locationManager = LocationManager.shared
    @State private var showWarningBanner = true

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
        GeometryReader { geo in
            ZStack(alignment: .top) {
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
                                    let profile = try await viewModel.fetchUserProfile(userID: supabaseUser.id.uuidString)
                                    viewModel.currentUser = profile
                                    viewModel.isSignedIn = true
                                    
                                    let diam = Double(diameterInput) ?? 0
                                    let finalProjectId = projectId ?? selectedProjectId!
                                    
                                    SaveScanedRecordToDatabase(height: height, diameter: diam, species: selectedSpecies, project_id: finalProjectId, user_id: profile.id, biomass_estimation: Bestimation)
                                    
                                    // Navigate to dashboard after saving
                                    authState = .Dashboard
                                } catch {
                                    print("Error fetch profile: \(error.localizedDescription)")
                                    viewModel.isSignedIn = false
                                }
                                
                            }
                        }
                    }) {
                        Text("Save")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 32)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.6)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 4)
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
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
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Dashboard button at the bottom
                    Button(action: {
                        // Navigation back to dashboard
                        authState = .Dashboard
                    }) {
                        Text("Dashboard")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 32)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.orange.opacity(0.8), Color.orange.opacity(0.6)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: Color.orange.opacity(0.4), radius: 8, x: 0, y: 4)
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
                    }
                    .accessibilityLabel("Dashboard")
                    .accessibilityHint("Tap to return to the dashboard")
                    .padding([.horizontal, .bottom])
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
                
                // ─────────────────────────────
                // 2️⃣ Floating banner
                if (locationManager.authorizationStatus == .denied
                    || locationManager.authorizationStatus == .restricted)
                   && showWarningBanner
                {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.white)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Location is off—scans won’t be tagged with coordinates.")
                                .foregroundColor(.white)
                                .font(.subheadline)
                            Text("To include coordinates in your scans, go to Settings > Privacy & Security > Location Services and enable location permission for this app.")
                                .foregroundColor(.white.opacity(0.9))
                                .font(.caption2)
                                .lineLimit(3)
                        }
                        Spacer()
                        Button(action: { showWarningBanner = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.orange)
                    .cornerRadius(8)
                    // shift down by the device’s top inset so it sits just under (or over) the notch
                    .padding(.top, geo.safeAreaInsets.top)
                    .padding(.horizontal, 16)
                    .zIndex(1)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
            }
            // make sure the banner can occupy the notch area
            // .ignoresSafeArea(edges: .top)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                locationManager.refreshAuthorization()
            }
        }
        .onAppear { _ = locationManager }
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
