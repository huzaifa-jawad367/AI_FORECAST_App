//
//  ProjectListView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 26/02/2025.
//

import SwiftUI

struct ProjectListView: View {
    @StateObject private var viewModel = ProjectViewModel()
    @Binding var authState: AuthState
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                NavigationLink {
                    ScansListView(authState: .constant(.ScansList))
                } label: {
                    // Using a List so pull-to-refresh works by default on iOS 16+
                    List {
                        ForEach(viewModel.projects) { project in
                            ProjectCardView(project: project)
                                .listRowSeparator(.hidden) // Remove default row style
                                .listRowInsets(EdgeInsets())
                        }
                    }
                    .listStyle(.plain)
                    .navigationTitle("Projects")
                    .refreshable {
                        await viewModel.fetchScans()
                    }
                    .task {
                        await viewModel.fetchScans()
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


#Preview {
    ProjectListView(authState: .constant(.ProjectsList))
}

