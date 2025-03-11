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
    var timestamp: Date
    var species: String
    
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

            // Measurements and info
            VStack(alignment: .leading, spacing: 15) {
                Text("Tree Measurements")
                    .font(.title2)
                    .fontWeight(.bold)

                HStack {
                    Text("Height:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(String(format: "%.2f meters", height))
                }
                .padding(.horizontal)

                HStack {
                    Text("Diameter:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(String(format: "%.2f cm", diameter))
                }
                .padding(.horizontal)

                HStack {
                    Text("Scan Time:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(timestamp.formatted(date: .abbreviated, time: .shortened))
                }
                .padding(.horizontal)
                
                HStack {
                    Text("Species:")
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    // Species dropdown
                    Text(species)
                }
                .padding(.horizontal)
                
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
            }
            .padding(.horizontal, 35)
            .padding(.bottom)
        }
        .navigationTitle("Scan Details")
    }
}

// Example preview
struct TreeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TreeDetailView(
            image: UIImage(systemName: "leaf")!, // Placeholder image
            height: 12.5,
            diameter: 30.2,
            timestamp: Date(),
            species: "Pine",
            authState: .constant(.ScanResultView)
        )
    }
}
