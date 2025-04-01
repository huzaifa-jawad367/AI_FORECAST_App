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
                            guard let supabaseUser = sessionManager.user else {
                                viewModel.isSignedIn = false
                                return
                            }
                            print("user is signed in\n\n")
                            
                            do {
                                print("Step 0")
                                let profile = try await viewModel.fetchUserProfile(userID: supabaseUser.id.uuidString)
                                print("Step 1")
                                viewModel.currentUser = profile
                                print("Step 2")
                                viewModel.isSignedIn = true
                                print("Step 3: Is signed in: \(profile)")
                                
                                try await saveProject(creator: profile.id, projectName: projectName, projectDescription: projectDescription)
                            } catch {
                                print("Error fetch profile: \(error.localizedDescription)")
                                viewModel.isSignedIn = false
                            }
                             
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
    
    private func saveProject(creator: String, projectName: String, projectDescription: String) async throws {
        
        
        let project_to_add = ProjectRecord_write(project_name: projectName, creator_name: creator, description: projectDescription, created_at: getCurrentTimestamp())
        
        print("The project instance I am adding: \(project_to_add)")
        
        try await client.database
            .from("projects")
            .insert(project_to_add)
            .execute()
        
        print("Saving project: \(projectName), \(projectDescription)")
    }

}

struct CreateProjectView_Previews: PreviewProvider {
    static var previews: some View {
        CreateProjectView()
            .environmentObject(SessionManager())
    }
}
