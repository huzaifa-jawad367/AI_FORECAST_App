//
//  CreateProjectView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 27/02/2025.
//

import SwiftUI

struct CreateProjectView: View {
    
    @Binding var authState: AuthState

    @Environment(\.dismiss) var dismiss
    @State private var projectName: String = ""
    @State private var projectDescription: String = ""
    
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
                    Button("Cancel") {
                        authState = .ProjectsList
                    }
                    .foregroundColor(.red)
                    
                    Spacer()
                    
                    Button("Save") {
                        saveProject()
                    }
                    .disabled(projectName.isEmpty)
                }
                .padding(.top)
            }
            .padding()
            .navigationTitle("New Project")
        }
    }
    
    private func saveProject() {
        // TODO: Save the project to the projects table in your Supabase database.
        print("Saving project: \(projectName), \(projectDescription)")
    }
}

struct CreateProjectView_Previews: PreviewProvider {
    static var previews: some View {
        CreateProjectView(authState: .constant(.CreateProject))
    }
}
