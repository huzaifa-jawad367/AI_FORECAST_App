//
//  ProjectCardView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 26/02/2025.
//

import SwiftUI

struct ProjectCardView: View {
    let project: ProjectRecord
    @State private var showMenu = false
    @State private var showDeleteConfirmation = false
    @State private var isDeleting = false
    
    // ✅ ADDED: Offline repository
    @StateObject private var projectRepository = ProjectRepository()
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(project.project_name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Menu button
                    Menu {
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete Project", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Project Options")
                    .accessibilityHint("Tap to see project options")
                }
                
                Text("Created By: \(String(project.creator_name ?? "-"))")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("Created at: \(String(project.created_at ?? "-"))")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                Text(project.description ?? "")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
               LinearGradient(
                   colors: [Color.green.opacity(0.8), Color.blue.opacity(0.8)],
                   startPoint: .topLeading,
                   endPoint: .bottomTrailing
               )
            )
            .cornerRadius(12)
            .shadow(radius: 4)
            .padding()
        }
        .alert("Delete Project", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                // Do nothing, just dismiss
            }
            Button("Delete", role: .destructive) {
                Task {
                    // ✅ CHANGED: Delete from local database first
                    await deleteProjectLocally()
                }
            }
        } message: {
            Text("Are you sure you want to delete '\(project.project_name)'? This action cannot be undone and will also delete all associated scans.")
        }
    }
    
    // ✅ NEW: Delete from local database first
    private func deleteProjectLocally() async {
        isDeleting = true
        
        do {
            // ✅ Delete from local database first (soft delete)
            try await projectRepository.delete(id: project.project_id)
            print("✅ Project soft deleted from local database: \(project.project_id)")
            
            // ✅ Then delete from Supabase for sync
            try await deleteProjectFromSupabase()
            
            // ✅ If Supabase delete succeeds, we could mark it as "synced deleted"
            // For now, we'll let the sync system handle this
            
            // Post notification for success
            await MainActor.run {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("ProjectDeletedSuccessfully"),
                        object: nil
                    )
                }
            }
            
        } catch {
            print("❌ Error deleting project: \(error.localizedDescription)")
            // Even if Supabase fails, we still have the local deletion
            // The sync system will retry later
        }
        
        await MainActor.run {
            isDeleting = false
        }
    }
    
    // ✅ RENAMED: Keep original Supabase delete logic
    private func deleteProjectFromSupabase() async throws {
        try await client.database
            .from("projects")
            .delete()
            .eq("id", value: project.project_id)
            .execute()
        
        print("✅ Project deleted from Supabase: \(project.project_id)")
    }
}

#Preview {
    ProjectCardView(project: ProjectRecord(project_id: "16089a3d-ca0d-4e73-ace4-ff4813bb9f0b", project_name: "Forest Restoration", creator_name: "huzaifajawad367", description: "Reforesting local area"))
}