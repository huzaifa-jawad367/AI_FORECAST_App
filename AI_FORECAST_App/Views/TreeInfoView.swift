//
//  TreeInfoView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 17/02/2025.
//

import SwiftUI

struct ScanResultView: View {
    let image: UIImage
    let height: Double
    let diameter: Double
    let timestamp: Date
    
    @Binding var authState: AuthState

    @State private var selectedSpecies: String = ""
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
                    Picker("Species", selection: $selectedSpecies) {
                        ForEach(speciesOptions, id: \.self) { species in
                            Text(species)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.2)))
                    .padding()
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
                
                Button(action: {
                    // If species is not selected, show alert
                    if selectedSpecies.isEmpty {
                        showAlert = true
                    } else {
                        // Navigate to ARView to measure next tree
                        
                    }
                }) {
                    Text("Continue Scan")
                        .foregroundColor(.white)
                        .padding()
//                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                }
            }
            .padding([.horizontal, .bottom])
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Species Not Selected"),
                    message: Text("Please select the tree species before proceeding."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .navigationTitle("Scan Details")
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
