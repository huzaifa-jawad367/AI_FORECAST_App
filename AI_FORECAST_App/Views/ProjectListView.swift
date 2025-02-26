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
            // Using a List so pull-to-refresh works by default on iOS 16+
            List {
                ForEach(viewModel.projects) { project in

                    ProjectCardView(project: project)
                        // Remove default row style
                        .listRowSeparator(.hidden)
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
    }
}

#Preview {
    ProjectListView(authState: .constant(.ProjectsList))
}

