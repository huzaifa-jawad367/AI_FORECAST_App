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
    
    // Offline database repositories
    private let projectRepository = ProjectRepository()
    private let scanRepository = ScanRepository()
    
    // Keep original Supabase method unchanged
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
                print("Error fetching user's projects:", error)
                projects = []
            }
        }

    /// Fetch projects from local Core Data database
    func fetchOfflineProjects(for userID: String? = nil) async {
        do {
            // Fetch all projects from local database
            let localProjects = try await projectRepository.fetchAllProjects()
            
            // Convert ProjectLocal to ProjectRecord for UI compatibility
            let projectRecords = localProjects.map { localProject in
                ProjectRecord(
                    project_id: localProject.id,
                    project_name: localProject.name,
                    creator_name: localProject.creatorName,
                    description: localProject.description,
                    created_at: DateFormatter.iso8601.string(from: localProject.createdAt)
                )
            }
            
            // Filter by user if provided (optional filtering)
            if let userID = userID {
                self.projects = projectRecords.filter { $0.creator_name == userID }
            } else {
                self.projects = projectRecords
            }
            
            print("✅ Fetched \(projects.count) projects from offline database")
            
        } catch {
            print("❌ Error fetching offline projects: \(error.localizedDescription)")
            projects = []
        }
    }
    
    /// Get project statistics from local database
    func getOfflineProjectStatistics(projectId: String) async -> (scanCount: Int, statistics: ProjectLocal.Statistics) {
        do {
            let scanCount = try await scanRepository.getScanCount(for: projectId)
            let statistics = try await projectRepository.getProjectStatistics(id: projectId)
            return (scanCount, statistics)
        } catch {
            print("❌ Error fetching project statistics: \(error.localizedDescription)")
            return (0, ProjectLocal.Statistics.empty)
        }
    }
    
    /// Search projects in local database
    func searchOfflineProjects(text: String) async {
        do {
            let localProjects = try await projectRepository.searchProjects(text: text)
            
            let projectRecords = localProjects.map { localProject in
                ProjectRecord(
                    project_id: localProject.id,
                    project_name: localProject.name,
                    creator_name: localProject.creatorName,
                    description: localProject.description,
                    created_at: DateFormatter.iso8601.string(from: localProject.createdAt)
                )
            }
            
            self.projects = projectRecords
            print("✅ Found \(projects.count) projects matching '\(text)'")
            
        } catch {
            print("❌ Error searching offline projects: \(error.localizedDescription)")
            projects = []
        }
    }
    
    /// Get projects with scan counts for dashboard/summary views
    func getOfflineProjectsWithScanCounts() async -> [(project: ProjectRecord, scanCount: Int)] {
        do {
            let projectsWithCounts = try await projectRepository.getProjectsWithScanCounts()
            
            return projectsWithCounts.map { (localProject, scanCount) in
                let projectRecord = ProjectRecord(
                    project_id: localProject.id,
                    project_name: localProject.name,
                    creator_name: localProject.creatorName,
                    description: localProject.description,
                    created_at: DateFormatter.iso8601.string(from: localProject.createdAt)
                )
                return (projectRecord, scanCount)
            }
        } catch {
            print("❌ Error fetching projects with scan counts: \(error.localizedDescription)")
            return []
        }
    }
}

// MARK: - DateFormatter Extension
private extension DateFormatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}