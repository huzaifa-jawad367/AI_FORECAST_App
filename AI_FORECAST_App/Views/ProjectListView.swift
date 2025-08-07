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
    @State private var showSuccessNotification = false
    
    var body: some View {
        
//        NavigationView {
            
        ZStack(alignment: .bottomTrailing) {
            // Success notification card
            if showSuccessNotification {
                VStack {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.title2)
                        
                        Text("Project successfully deleted!")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green.opacity(0.9), Color.green.opacity(0.7)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: Color.green.opacity(0.4), radius: 8, x: 0, y: 4)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1)
            }
            
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
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ProjectDeletedSuccessfully"))) { _ in
            showSuccessNotification = true
            
            // Refresh the projects list
            Task {
                guard let uid = sessionManager.user?.id.uuidString else { return }
                await viewModel.fetchProjects(for: uid)
            }
            
            // Hide notification after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                showSuccessNotification = false
            }
        }
//        }
    
        
        
    }
}


#Preview {
    ProjectListView(authState: .constant(.ProjectsList))
}

