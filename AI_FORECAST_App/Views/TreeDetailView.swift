//
//  TreeDetailView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 27/02/2025.
//

import SwiftUI

struct TreeDetailView: View {
    let image: UIImage
    var height: Double
    var diameter: Double
    var timestamp: String
    var species: String
    var biomass_estimation: Float
    let scanId: String // Add scan ID for deletion
    
    @Binding var authState: AuthState
    @EnvironmentObject var sessionManager: SessionManager
    
    @State private var selectedSpecies: String = ""

    // Toggle for alert
    @State private var showAlert = false
    @State private var showDeleteConfirmation = false
    @State private var isDeleting = false
    @State private var alertMessage = ""
    @State private var showSuccessNotification = false

    var body: some View {
        ZStack {
            VStack {
                // Debug info
                // Text("Current authState: \(String(describing: authState))")
                //     .font(.caption)
                //     .foregroundColor(.gray)
                //     .padding(.top)
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
                    if let date = ISO8601DateFormatter().date(from: timestamp) {
                        Text(date.formatted(date: .abbreviated, time: .shortened))
                    } else {
                        // Fallback if the string cannot be parsed
                        Text(timestamp)
                    }
                }
                .padding(.horizontal)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Scan Time: \(ISO8601DateFormatter().date(from: timestamp)?.formatted(date: .abbreviated, time: .shortened) ?? timestamp)")
                
                HStack {
                    Text("Species:")
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    // Species dropdown
                    Text(species)
                }
                .padding(.horizontal)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Species: \(species)")
                
                HStack {
                    Text("Biomass Estimation:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text("\(biomass_estimation)")
                }
                .padding(.horizontal)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Biomass Estimation: Not available")
                
            }
            .padding()
            
//            Button(action: {
//                // If species is not selected, show alert
//                if selectedSpecies.isEmpty {
//                    showAlert = true
//                } else {
//                    
//                }
//            }) {
//                Text("Save")
//                    .foregroundColor(.white)
//                    .padding()
//                    .frame(width: 200)
//                    .background(Color.blue)
//                    .cornerRadius(20)
//            }
            
            Spacer()
            
            // Navigation buttons at the bottom
            Button(action: {
                // Haptic feedback for button press
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
                showDeleteConfirmation = true
            }) {
                HStack {
                    if isDeleting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    Text(isDeleting ? "Deleting..." : "Delete")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.red.opacity(0.8), Color.red.opacity(0.6)]),
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
                .shadow(color: Color.red.opacity(0.4), radius: 8, x: 0, y: 4)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
            }
            .disabled(isDeleting)
            .accessibilityLabel("Delete Scan")
            .accessibilityHint("Tap to delete this scan")
            .padding([.horizontal, .bottom])
            .alert("Delete Scan", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    // Do nothing, just dismiss
                }
                Button("Delete", role: .destructive) {
                    deleteScan()
                }
            } message: {
                Text("Are you sure you want to delete this scan? This action cannot be undone.")
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(alertMessage.isEmpty ? "An error occurred while deleting the scan." : alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .padding(.horizontal, 35)
            .padding(.bottom)
            
            }
            .navigationTitle("Scan Details")
            .accessibilityIdentifier("treeDetailView")
            
            // Success notification card
            if showSuccessNotification {
                VStack {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.title2)
                        
                        Text("Scan successfully deleted!")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green.opacity(0.9), Color.green.opacity(0.7)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: Color.green.opacity(0.4), radius: 8, x: 0, y: 4)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1)
            }
        }
    }
    
    private func deleteScan() {
        isDeleting = true
        
        Task {
            do {
                // Delete the scan from Supabase
                try await client.database
                    .from("scans")
                    .delete()
                    .eq("id", value: scanId)
                    .execute()
                
                print("Scan deleted successfully: \(scanId)")
                
                // Show success notification and navigate back to ScansList
                await MainActor.run {
                    isDeleting = false
                    showSuccessNotification = true
                    
                    // Hide notification after 2 seconds and navigate
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        showSuccessNotification = false
                        authState = .ScansList
                    }
                }
                
            } catch {
                print("Error deleting scan: \(error.localizedDescription)")
                
                await MainActor.run {
                    isDeleting = false
                    alertMessage = "Failed to delete scan: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}

// Example preview
struct TreeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TreeDetailView(
            image: UIImage(systemName: "leaf")!, // Placeholder image
            height: 12.5,
            diameter: 30.2,
            timestamp: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short),
            species: "Pine",
            biomass_estimation: 35.9,
            scanId: "preview-scan-id",
            authState: .constant(.ScanResultView)
        )
    }
}
