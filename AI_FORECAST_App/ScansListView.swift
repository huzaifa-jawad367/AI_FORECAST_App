//
//  ScansListView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 23/02/2025.
//

import SwiftUI

struct ScansListView: View {
    @StateObject private var viewModel = ScansViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.scans) { scan in
                ScanCardView(scan: scan)
                    .listRowSeparator(.hidden)  // optional: hides row separators
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
    }
}

struct ScansListView_Previews: PreviewProvider {
    static var previews: some View {
        ScansListView()
    }
}
