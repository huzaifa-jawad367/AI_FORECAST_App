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
    
    @State private var selectedSpecies: String = ""

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
                
                Spacer()
                
                Button(action: {
                    authState = .scanPage
                }) {
                    Text("Continue Scan")
                        .foregroundColor(.white)
                        .padding()
//                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .accessibilityLabel("Continue Scan")
                .accessibilityHint("Tap to continue scanning another tree")
                
            }
            .padding(.horizontal, 35)
            .padding(.bottom)
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
