//
//  ScanRecord.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 20/02/2025.
//

import SwiftUI

struct ScanRecord: Identifiable, Codable {
    var id: String { scan_id }
    
    let scan_id: String
    let height: Double
    let diameter: Double
    let species: String
    let scan_time: String
    let project_name: String?
    
    // Nullable fields
    var user_name: String?          // Nullable
    var biomass_estimation: Float?  // Nullable
    var latitude: Float?            // Nullable
    var longitude: Float?           // Nullable
    
    // Map JSON keys from Supabase to your property names
    enum CodingKeys: String, CodingKey {
        case scan_id = "id"
        case species = "tree_species"
        case height = "tree_height"
        case diameter = "tree_diameter"
        case scan_time = "created_at"
        case project_name = "projects.name"
        case user_name = "users.full_name"
        case biomass_estimation
        case latitude
        case longitude
        // You might also want case created_by = "created_by"
    }
}
