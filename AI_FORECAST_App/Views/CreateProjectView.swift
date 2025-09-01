//
//  CreateProjectView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 27/02/2025.
//

import SwiftUI

struct CreateProjectView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var projectName: String = ""
    @State private var projectDescription: String = ""
    
    @StateObject private var viewModel = SettingsViewModel()
    
    @EnvironmentObject var sessionManager: SessionManager
    
    // ✅ ADDED: Offline repository
    @StateObject private var projectRepository = ProjectRepository()
    
    var body: some View {
        NavigationView {
            
            VStack(alignment: .leading, spacing: 16) {
                // Project Name
                Text("Project Name *")
                    .font(.headline)
                TextField("Enter project name", text: $projectName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // Project Description
                Text("Project Description")
                    .font(.headline)
                TextEditor(text: $projectDescription)
                    .frame(height: 150)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                
                Spacer()
                
                // Buttons
                HStack {
                    Spacer()
                    
                    Button("Save") {
                        Task {
                            // ✅ CHANGED: Save to local database first, then sync to Supabase
                            await saveProjectLocally()
                        }
                    }
                    .disabled(projectName.isEmpty)
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .padding()
            .navigationTitle("New Project")
            
            
        }
    }
    
    private func getCurrentTimestamp() -> String {
        let now = Date()
        
        // Format the main data and time
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let baseString = formatter.string(from: now)
        
        // Extract the nanosecond component and convert to microsecond
        let calendar = Calendar.current
        let nanoseconds = calendar.component(.nanosecond, from: now)
        let microseconds = nanoseconds / 1000

        // Combine the formatted date string with the microseconds (6 digits)
        return String(format: "%@.%06d", baseString, microseconds)
    }
    
    // ✅ NEW: Save to local database first
    private func saveProjectLocally() async {
        guard let supabaseUser = sessionManager.user else {
            viewModel.isSignedIn = false
            print("❌ User not signed in")
            return
        }
        
        do {
            // Get user profile for creator name
            let profile = try await viewModel.fetchUserProfile(userID: supabaseUser.id.uuidString)

            print("Step 1: User profile fetched")

            // ✅ Create local project object
            let localProject = ProjectLocal(
                name: projectName,
                description: projectDescription.isEmpty ? nil : projectDescription,
                creatorName: profile.username
            )

            print("Step 2: Local project object created")
            
            // ✅ Save to local database first
            try await projectRepository.create(localProject)
            
            print("✅ Project saved to local database: \(localProject.name)")
            
            // ✅ Then save to Supabase for sync
            try await saveProjectToSupabase(creator: profile.user_id, projectName: projectName, projectDescription: projectDescription)

            print("Step 3: Project saved to Supabase")

            // ✅ Mark as synced if Supabase save succeeds
            try await projectRepository.markAsSynced(ids: [localProject.id])
            print("✅ Project marked as synced: \(localProject.id)")
            
            // Navigate back
            await MainActor.run {
                // Post notification to refresh project list
                NotificationCenter.default.post(name: NSNotification.Name("ProjectCreatedSuccessfully"), object: nil)
                dismiss()
            }
            
        } catch {
            print("❌ Error saving project: \(error.localizedDescription)")
            // Even if Supabase fails, we still have the local copy
            // The sync system will retry later
        }
    }
    
    // ✅ RENAMED: Keep original Supabase save logic
    private func saveProjectToSupabase(creator: String, projectName: String, projectDescription: String) async throws {
        let project_to_add = ProjectRecord_write(
            project_name: projectName, 
            creator_name: creator, 
            description: projectDescription, 
            created_at: getCurrentTimestamp()
        )
        
        print("The project instance I am adding: \(project_to_add)")
        
        try await client.database
            .from("projects")
            .insert(project_to_add)
            .execute()
        
        print("✅ Project saved to Supabase: \(projectName)")
    }
}

struct CreateProjectView_Previews: PreviewProvider {
    static var previews: some View {
        CreateProjectView()
            .environmentObject(SessionManager())
    }
}