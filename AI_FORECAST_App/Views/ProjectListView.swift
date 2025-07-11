//
//  ProjectListView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 26/02/2025.
//

import SwiftUI

struct ProjectListView: View {
    @EnvironmentObject private var sessionManager: SessionManager
    @StateObject private var viewModel = ProjectViewModel()
    @Binding var authState: AuthState
    
    var body: some View {
        
//        NavigationView {
            
        ZStack(alignment: .bottomTrailing) {
            
//            NavigationLink {
//                ScansListView(authState: .constant(.ScansList), projectID: "8f024da5-07a5-47ef-908d-abb20e856755")
//            } label: {
//                // Using a List so pull-to-refresh works by default on iOS 16+
//                List {
//                    ForEach(viewModel.projects) { project in
//                        ProjectCardView(project: project)
//                            .listRowSeparator(.hidden) // Remove default row style
//                            .listRowInsets(EdgeInsets())
//                            .accessibilityElement(children: .combine)
//                            .accessibilityLabel("Project: \(project)")
//                        
//                    }
//                }
//                .listStyle(.plain)
//                .navigationTitle("Projects")
//                .accessibilityLabel("Projects List")
//                .accessibilityHint("Swipe left or right to browse your projects")
//                .refreshable {
//                    await viewModel.fetchScans()
//                }
//                .task {
//                    await viewModel.fetchScans()
//                }
//            }
            
            
            List(viewModel.projects) { project in
              NavigationLink {
                ScansListView(
                    authState: $authState,
                    projectID: project.id
                )
              } label: {
                ProjectCardView(project: project)
              }
              .listRowSeparator(.hidden)
              .listRowInsets(.init())
            }
            // restore your plain styling & nav-title
            .listStyle(.plain)
            .scrollContentBackground(.hidden)       // iOS16+—hides the grouped background
            .navigationTitle("Projects")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                guard let uid = sessionManager.user?.id.uuidString else { return }
                await viewModel.fetchProjects(for: uid)
            }
            .task {
                guard let uid = sessionManager.user?.id.uuidString else { return }
                await viewModel.fetchProjects(for: uid)
            }
//            .refreshable { await viewModel.fetchProjects() }
//            .task { await viewModel.fetchProjects() }


            
            // Floating circular button at the bottom right
            NavigationLink(destination: CreateProjectView()) {
                Image(systemName: "plus")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding(50)
            .accessibilityLabel("Create Project")
            .accessibilityHint("Tap to create a new project")
        }
//        }
    
        
        
    }
}


#Preview {
    ProjectListView(authState: .constant(.ProjectsList))
}

