//
//  ProjectRepository.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 27/08/2025.
//

import Foundation
import CoreData
import Combine

/// Repository for managing project data with Core Data
@MainActor
final class ProjectRepository: ObservableObject {
    private let persistenceController: PersistenceController
    private var cancellables = Set<AnyCancellable>()
    
    @Published var projects: [ProjectLocal] = []
    @Published var isLoading = false
    @Published var error: PersistenceError?
    
    init(persistenceController: PersistenceController? = nil) {
        if let controller = persistenceController {
            self.persistenceController = controller
        } else {
            // Access the shared instance directly; class is @MainActor isolated
            self.persistenceController = PersistenceController.shared
        }
    }
    
    // MARK: - CRUD Operations
    
    /// Create a new project
    func create(_ project: ProjectLocal) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            print("🔄 Creating project in local database: \(project.name)")
            
            try await persistenceController.performBackgroundTask { context in
                print("📝 Creating ProjectEntity in background context")
                let entity = ProjectEntity.create(from: project, in: context)
                print("💾 Saving context with project: \(entity.projectName ?? "unknown")")
                try context.save()
                print("✅ Context saved successfully")
            }
            
            print("🔄 Refreshing projects list...")
            await refreshProjects()
            print("✅ Project created: \(project.id)")
        } catch {
            print("❌ Error creating project: \(error.localizedDescription)")
            self.error = .saveFailure(error)
            throw error
        }
    }
    
    /// Fetch all active projects
    func fetchAllProjects() async throws -> [ProjectLocal] {
        isLoading = true
        defer { isLoading = false }
        
        do {
            print("🔄 Fetching all active projects from Core Data...")
            
            let projectEntities = try await persistenceController.performBackgroundTask { context in
                let request = ProjectEntity.activeProjectsFetchRequest()
                print("📋 Executing fetch request for active projects")
                let entities = try context.fetch(request)
                print("📊 Found \(entities.count) project entities")
                return entities
            }
            
            let projects = projectEntities.map { $0.toLocal() }
            print("🔄 Converting \(projectEntities.count) entities to ProjectLocal objects")
            
            await MainActor.run {
                self.projects = projects
                print("📱 Updated @Published projects array with \(projects.count) projects")
            }
            
            print("✅ Successfully fetched \(projects.count) projects")
            return projects
        } catch {
            print("❌ Error fetching projects: \(error.localizedDescription)")
            self.error = .fetchFailure(error)
            throw error
        }
    }
    
    /// Fetch a specific project by ID
    func fetchProject(id: String) async throws -> ProjectLocal? {
        do {
            let projectEntity = try await persistenceController.performBackgroundTask { context in
                let request = ProjectEntity.projectFetchRequest(id: id)
                return try context.fetch(request).first
            }
            
            return projectEntity?.toLocal()
        } catch {
            self.error = .fetchFailure(error)
            throw error
        }
    }
    
    /// Update an existing project
    func update(_ project: ProjectLocal) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await persistenceController.performBackgroundTask { context in
                let request = ProjectEntity.projectFetchRequest(id: project.id)
                
                guard let entity = try context.fetch(request).first else {
                    throw PersistenceError.entityNotFound
                }
                
                entity.update(from: project)
                try context.save()
            }
            
            await refreshProjects()
            print("✅ Project updated: \(project.id)")
        } catch {
            self.error = .saveFailure(error)
            throw error
        }
    }
    
    /// Delete a project (soft delete)
    func delete(id: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await persistenceController.performBackgroundTask { context in
                let request = ProjectEntity.projectFetchRequest(id: id)
                
                guard let entity = try context.fetch(request).first else {
                    throw PersistenceError.entityNotFound
                }
                
                entity.deletedAt = Date()
                entity.updatedAt = Date()
                try context.save()
            }
            
            await refreshProjects()
            print("✅ Project soft deleted: \(id)")
        } catch {
            self.error = .saveFailure(error)
            throw error
        }
    }
    
    /// Permanently delete a project (hard delete) - also deletes all scans
    func permanentlyDelete(id: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await persistenceController.performBackgroundTask { context in
                let request = ProjectEntity.projectFetchRequest(id: id)
                
                guard let entity = try context.fetch(request).first else {
                    throw PersistenceError.entityNotFound
                }
                
                // Core Data cascade delete will handle related scans
                context.delete(entity)
                try context.save()
            }
            
            await refreshProjects()
            print("✅ Project permanently deleted: \(id)")
        } catch {
            self.error = .saveFailure(error)
            throw error
        }
    }
    
    // MARK: - Specialized Queries
    
    /// Search projects by text (name, description)
    func searchProjects(text: String) async throws -> [ProjectLocal] {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return try await fetchAllProjects()
        }
        
        do {
            let projectEntities = try await persistenceController.performBackgroundTask { context in
                let request = ProjectEntity.projectsFetchRequest(searchText: text)
                return try context.fetch(request)
            }
            
            return projectEntities.map { $0.toLocal() }
        } catch {
            self.error = .fetchFailure(error)
            throw error
        }
    }
    
    /// Fetch projects by creator
    func fetchProjects(createdBy creator: String) async throws -> [ProjectLocal] {
        do {
            let projectEntities = try await persistenceController.performBackgroundTask { context in
                let request = ProjectEntity.projectsFetchRequest(createdBy: creator)
                return try context.fetch(request)
            }
            
            return projectEntities.map { $0.toLocal() }
        } catch {
            self.error = .fetchFailure(error)
            throw error
        }
    }
    
    /// Fetch unsynced projects
    func fetchUnsyncedProjects() async throws -> [ProjectLocal] {
        do {
            let projectEntities = try await persistenceController.performBackgroundTask { context in
                let request = ProjectEntity.unsyncedProjectsFetchRequest()
                return try context.fetch(request)
            }
            
            return projectEntities.map { $0.toLocal() }
        } catch {
            self.error = .fetchFailure(error)
            throw error
        }
    }
    
    /// Mark projects as synced
    func markAsSynced(ids: [String]) async throws {
        do {
            try await persistenceController.performBackgroundTask { context in
                for id in ids {
                    let request = ProjectEntity.projectFetchRequest(id: id)
                    if let entity = try context.fetch(request).first {
                        entity.synced = true
                        entity.updatedAt = Date()
                    }
                }
                try context.save()
            }
            
            print("✅ Marked \(ids.count) projects as synced")
        } catch {
            self.error = .saveFailure(error)
            throw error
        }
    }
    
    // MARK: - Statistics and Analytics
    
    /// Get project statistics
    func getProjectStatistics(id: String) async throws -> ProjectLocal.Statistics {
        do {
            return try await persistenceController.performBackgroundTask { context in
                let request = ProjectEntity.projectFetchRequest(id: id)
                guard let entity = try context.fetch(request).first else {
                    return ProjectLocal.Statistics.empty
                }
                return entity.getStatistics()
            }
        } catch {
            self.error = .fetchFailure(error)
            throw error
        }
    }
    
    /// Get total project count
    func getTotalProjectCount() async throws -> Int {
        do {
            return try await persistenceController.performBackgroundTask { context in
                let request = ProjectEntity.activeProjectsFetchRequest()
                return try context.count(for: request)
            }
        } catch {
            self.error = .fetchFailure(error)
            throw error
        }
    }
    
    /// Get projects with scan counts
    func getProjectsWithScanCounts() async throws -> [(project: ProjectLocal, scanCount: Int)] {
        do {
            return try await persistenceController.performBackgroundTask { context in
                let request = ProjectEntity.activeProjectsFetchRequest()
                let entities = try context.fetch(request)
                
                return entities.map { entity in
                    let project = entity.toLocal()
                    let scanCount = (entity.scans as? Set<ScanEntity>)?.filter { $0.deletedAt == nil }.count ?? 0
                    return (project: project, scanCount: scanCount)
                }
            }
        } catch {
            self.error = .fetchFailure(error)
            throw error
        }
    }
    
    /// Get recent projects (last 30 days)
    func getRecentProjects() async throws -> [ProjectLocal] {
        do {
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            
            let projectEntities = try await persistenceController.performBackgroundTask { context in
                let request = ProjectEntity.activeProjectsFetchRequest()
                request.predicate = NSPredicate(
                    format: "deletedAt == nil AND updatedAt >= %@",
                    thirtyDaysAgo as NSDate
                )
                return try context.fetch(request)
            }
            
            return projectEntities.map { $0.toLocal() }
        } catch {
            self.error = .fetchFailure(error)
            throw error
        }
    }
    
    // MARK: - Helper Methods
    
    /// Refresh the published projects array
    private func refreshProjects() async {
        do {
            _ = try await fetchAllProjects()
        } catch {
            print("❌ Failed to refresh projects: \(error)")
        }
    }
    
    /// Clear all projects (for logout/reset)
    func clearAllProjects() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await persistenceController.performBackgroundTask { context in
                let request: NSFetchRequest<NSFetchRequestResult> = ProjectEntity.fetchRequest()
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
                try context.execute(deleteRequest)
                try context.save()
            }
            
            await MainActor.run {
                self.projects = []
            }
            
            print("✅ All projects cleared")
        } catch {
            self.error = .saveFailure(error)
            throw error
        }
    }
    
    /// Check if a project exists
    func projectExists(id: String) async throws -> Bool {
        do {
            return try await persistenceController.performBackgroundTask { context in
                let request = ProjectEntity.projectFetchRequest(id: id)
                request.fetchLimit = 1
                return try context.count(for: request) > 0
            }
        } catch {
            self.error = .fetchFailure(error)
            throw error
        }
    }
}

// MARK: - Batch Operations
extension ProjectRepository {
    
    /// Create multiple projects in a batch
    func createBatch(_ projects: [ProjectLocal]) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await persistenceController.performBackgroundTask { context in
                for project in projects {
                    _ = ProjectEntity.create(from: project, in: context)
                }
                try context.save()
            }
            
            await refreshProjects()
            print("✅ Created batch of \(projects.count) projects")
        } catch {
            self.error = .saveFailure(error)
            throw error
        }
    }
    
    /// Update multiple projects in a batch
    func updateBatch(_ projects: [ProjectLocal]) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await persistenceController.performBackgroundTask { context in
                for project in projects {
                    let request = ProjectEntity.projectFetchRequest(id: project.id)
                    if let entity = try context.fetch(request).first {
                        entity.update(from: project)
                    }
                }
                try context.save()
            }
            
            await refreshProjects()
            print("✅ Updated batch of \(projects.count) projects")
        } catch {
            self.error = .saveFailure(error)
            throw error
        }
    }
    
    /// Export projects as JSON (for backup/migration)
    func exportProjectsAsJSON() async throws -> Data {
        do {
            let projects = try await fetchAllProjects()
            return try JSONEncoder().encode(projects)
        } catch {
            throw PersistenceError.saveFailure(error)
        }
    }
    
    /// Import projects from JSON
    func importProjectsFromJSON(_ data: Data) async throws {
        do {
            let projects = try JSONDecoder().decode([ProjectLocal].self, from: data)
            try await createBatch(projects)
        } catch {
            throw PersistenceError.saveFailure(error)
        }
    }
}
