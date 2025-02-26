//
//  ScansViewModel.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 23/02/2025.
//

import Foundation
import Supabase
import SwiftUI

@MainActor
class ScansViewModel: ObservableObject {
    @Published var scans: [ScanRecord] = []
    
    func fetchScans() async {
        do {
            let response = try await client.database
                .from("scans")
                .select("""
                    id,
                    tree_height,
                    tree_diameter,
                    tree_species,
                    created_at,
                    projects(name),
                    users(full_name),
                    biomass_estimation,
                    latitude,
                    longitude
                """)
                .execute()
            
            
            
            // Decode the raw Data into an array of ScanRecord
            let records = try JSONDecoder().decode([ScanRecord].self, from: response.data)
            self.scans = records
        } catch {
            print("Error fetching scans: \(error.localizedDescription)")
        }

    }
}
