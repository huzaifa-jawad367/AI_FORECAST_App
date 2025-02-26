//
//  ProjectRecord.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 26/02/2025.
//

struct ProjectRecord: Identifiable, Codable {
    // Computed property for SwiftUI
    var id: String { project_id }
    
    let project_id: String
    var project_name: String
    var creator_name: String?
    var description: String?
    var created_at: String?
    
    // Map JSON keys from Supabase to your property names
    enum CodingKeys: String, CodingKey {
        case project_id = "id"
        case project_name = "name"
        case description
        case created_at
        case creator_name = "users.full_name"
        // You might also want case created_by = "created_by"
        
    }
}


