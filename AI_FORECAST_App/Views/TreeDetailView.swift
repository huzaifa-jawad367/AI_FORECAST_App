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
    
    @Binding var authState: AuthState
    @EnvironmentObject var sessionManager: SessionManager
    
    @State private var selectedSpecies: String = ""

    // Toggle for alert
    @State private var showAlert = false

    var body: some View {
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
            // Button(action: {
            //     // Navigation back to dashboard
            //     print("Dashboard button pressed - changing authState to Dashboard")
            //     print("Before change - authState: \(authState)")
            //     authState = .Dashboard
            //     sessionManager.authState = .Dashboard
            //     print("After change - authState: \(authState)")
            //     print("SessionManager authState: \(sessionManager.authState)")
                
            //     // Also check SessionManager state
            //     DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            //         print("SessionManager authState after delay: \(sessionManager.authState)")
            //     }
            // }) {
            //     Text("Dashboard")
            //         .font(.headline)
            //         .fontWeight(.semibold)
            //         .foregroundColor(.white)
            //         .padding(.vertical, 16)
            //         .padding(.horizontal, 32)
            //         .frame(maxWidth: .infinity)
            //         .background(
            //             LinearGradient(
            //                 gradient: Gradient(colors: [Color.orange.opacity(0.8), Color.orange.opacity(0.6)]),
            //                 startPoint: .topLeading,
            //                 endPoint: .bottomTrailing
            //             )
            //         )
            //         .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            //         .overlay(
            //             RoundedRectangle(cornerRadius: 20)
            //                 .stroke(Color.white.opacity(0.3), lineWidth: 1)
            //         )
            //         .clipShape(RoundedRectangle(cornerRadius: 20))
            //         .shadow(color: Color.orange.opacity(0.4), radius: 8, x: 0, y: 4)
            //         .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
            // }
            // .accessibilityLabel("Dashboard")
            // .accessibilityHint("Tap to return to the dashboard")
            // .padding([.horizontal, .bottom])
            // .alert(isPresented: $showAlert) {
            //     Alert(
            //         title: Text("Species Not Selected"),
            //         message: Text("Please select the tree species before proceeding."),
            //         dismissButton: .default(Text("OK"))
            //     )
            // }
            // .padding(.horizontal, 35)
            // .padding(.bottom)
            
        }
        .navigationTitle("Scan Details")
        .accessibilityIdentifier("treeDetailView")
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
            authState: .constant(.ScanResultView)
        )
    }
}
