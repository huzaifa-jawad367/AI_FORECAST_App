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
    
    func fetchProjects(for userID: String) async {
            do {
                // 1) grab all membership rows for this user
                let memberResp = try await client.database
                    .from("project_members")
                    .select("id, project_id")
                    .eq("user_id", value: userID)
                    .execute()

                let members = try JSONDecoder()
                    .decode([ProjectMemberRecord].self, from: memberResp.data)
                let ids = members.map(\.project_id)

                guard !ids.isEmpty else {
                    projects = []
                    return
                }

                // 2) fetch only those projects whose id is in `ids`
                let projResp = try await client.database
                    .from("projects")
                    .select("""
                        id,
                        name,
                        description,
                        created_by,
                        created_at,
                        users(full_name)
                    """)
                    .in("id", value: ids)
                    .execute()

                projects = try JSONDecoder()
                    .decode([ProjectRecord].self, from: projResp.data)

            } catch {
                print("Error fetching user’s projects:", error)
                projects = []
            }
        }

}
