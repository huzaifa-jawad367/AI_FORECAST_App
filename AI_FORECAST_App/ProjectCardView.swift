//
//  ProjectCardView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 26/02/2025.
//

import SwiftUI

struct ProjectCardView: View {
    let project: ProjectRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(project.project_name)
                .font(.headline)
                .foregroundColor(.white)
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
}

#Preview {
    ProjectCardView(project: ProjectRecord(project_id: "16089a3d-ca0d-4e73-ace4-ff4813bb9f0b", project_name: "Forest Restoration", creator_name: "huzaifajawad367", description: "Reforesting local area"))
}
