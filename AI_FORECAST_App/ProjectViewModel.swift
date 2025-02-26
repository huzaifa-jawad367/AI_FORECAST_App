//
//  ProjectViewModel.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 26/02/2025.
//

import Foundation
import Supabase
import SwiftUI

@MainActor
class ProjectViewModel: ObservableObject {
    @Published var projects: [ProjectRecord] = []
    
    func fetchScans() async {
        do {
            
            let response = try await client.database
                .from("projects")
                .select("""
                    id, 
                    name, 
                    description, 
                    created_by, 
                    created_at, 
                    users(full_name)
                """)
                .execute()
            
            
            // Decode the raw Data into an array of ScanRecord
            let records = try JSONDecoder().decode([ProjectRecord].self, from: response.data)
            self.projects = records
        } catch {
            print("Error fetching scans: \(error.localizedDescription)")
        }

    }
}
