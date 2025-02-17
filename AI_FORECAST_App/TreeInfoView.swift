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
    
    @State private var selectedSpecies: String = ""
    let speciesOptions = ["Oak", "Pine", "Maple", "Birch", "Spruce", "Other"]
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
            
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
            
            Spacer()
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
            timestamp: Date()
        )
    }
}
