//
//  ScansListView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 23/02/2025.
//

import SwiftUI

struct ScansListView: View {
    @Binding var authState: AuthState
    @StateObject private var viewModel = ScansViewModel()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                NavigationLink {
                    TreeDetailView(
                        image: UIImage(systemName: "leaf")!, // Placeholder image
                        height: 12.5,
                        diameter: 30.2,
                        timestamp: Date(),
                        species: "Pine",
                        authState: .constant(.ScanResultView)
                    )
                } label: {
                    List(viewModel.scans) { scan in
                        ScanCardView(scan: scan)
//                            .listRowSeparator(.hidden)  // optional: hides row separators
                    }
                    .listStyle(PlainListStyle())
                    .navigationTitle("Scans")
                    .onAppear {
                        // Load scans when the view appears.
                        Task {
                            await viewModel.fetchScans()
                        }
                    }
                }
                
                
                // Floating circular button at the bottom right
                NavigationLink(destination: CameraView()) {
                    Image(systemName: "plus")
                        .font(.system(size: 36))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(50)
            }
            
            
        }
    }
}


struct CameraView: View {
    var body: some View {
        Text("Camera Page")
            .font(.largeTitle)
            .padding()
    }
}

struct ScansListView_Previews: PreviewProvider {
    static var previews: some View {
        ScansListView(authState: .constant(.ScansList))
    }
}
