//
//  ScansListView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 23/02/2025.
//

import SwiftUI

struct ScansListView: View {
    @Binding var authState: AuthState
    let projectID: String
    @StateObject private var viewModel = ScansViewModel()
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List(viewModel.scans) { scan in
                NavigationLink {
                    TreeDetailView(
                        // TODO: Save the image in database and retrieve it
                        image: UIImage(systemName: "leaf")!, // Placeholder image to be changed after AR implementation
                        height: scan.height,
                        diameter: scan.diameter,
                        timestamp: scan.scan_time,
                        species: scan.species,
                        biomass_estimation: scan.biomass_estimation ?? -1.0,
                        authState: .constant(.ScanResultView)
                    )
                } label: {
                    //                List(viewModel.scans) { scan in
                    ScanCardView(scan: scan)
                    //                            .listRowSeparator(.hidden)  // optional: hides row separators
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Scans")
            // Accessibility for the scans list
            .accessibilityLabel("List of Scans")
            .accessibilityHint("Swipe through the scans to view details")
            .onAppear {
                // Load scans when the view appears.
                Task {
                    await viewModel.fetchScans(projectID: projectID)
                    
                    for scan in viewModel.scans {
                        print("----- Scan Record -----")
                        print("ID: \(scan.id)")
                        print("Tree Height: \(scan.height)")
                        print("Tree Diameter: \(scan.diameter)")
                        print("Tree Species: \(scan.species)")
                        print("Created At: \(scan.scan_time)")
                        print("Biomass Estimation: \(scan.biomass_estimation.map { String($0) } ?? "Not calculated")")
                        print("Latitude: \(scan.latitude.map { String($0) } ?? "Not present")")
                        print("Longitude: \(scan.longitude.map { String($0) } ?? "Not present")")
                        print("-----------------------")
                    }
                }
            }
            .accessibilityElement(children: .contain)
            
            
            // Floating circular button at the bottom right
            NavigationLink(destination: TreeMeasurementView(authState: .constant(.scanPage))) {
                Image(systemName: "plus")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding(50)
            .accessibilityLabel("Add New Scan")
            .accessibilityHint("Tap to open the camera and capture a new scan")
        }
        .accessibilityIdentifier("scansListView")
            
    }
}


struct CameraView: View {
    var body: some View {
        Text("Camera Page")
            .font(.largeTitle)
            .padding()
            .accessibilityLabel("Camera Page")
            .accessibilityHint("This is the page where you capture a new scan")
    }
}

struct ScansListView_Previews: PreviewProvider {
    static var previews: some View {
        ScansListView(
            authState: .constant(.ScansList),
            projectID: "16089a3d-ca0d-4e73-ace4-ff4813bb9f0b"
        )
        .environmentObject(SessionManager())
    }
}
