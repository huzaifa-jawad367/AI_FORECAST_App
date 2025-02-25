//
//  ScanCardView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 22/02/2025.
//
import SwiftUI

struct ScanCardView: View {
    let scan: ScanRecord

    var body: some View {
        
            
        VStack(alignment: .leading, spacing: 8) {
            Text(scan.species)
                .font(.headline)
                .foregroundColor(.white)
            Text("Height: \(String(format: "%.2f", scan.height)) m")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            Text("Diameter: \(String(format: "%.2f", scan.diameter)) cm")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            Text(scan.scan_time)
                .font(.footnote)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.green)
        .cornerRadius(12)
        .shadow(radius: 4)
        .padding()
    }
}

// Example preview
struct ScanCardView_Previews: PreviewProvider {
    static var previews: some View {
        ScanCardView(
            scan: ScanRecord(scan_id: "0034dce6-a317-479b-912f-37f91c92719e", height: 13.21, diameter: 30.20, species: "Maple", scan_time: "2024-05-19 00:00:00", project_name: "Project1", user_name: "Huzaifa Jawad", biomass_estimation: 21.23, latitude: 71.23, longitude: 71.26)
        )
    }
}
