//
//  ProjectEntity+Mapping.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 27/08/2025.
//

import Foundation
import CoreData

// MARK: - ProjectEntity Core Data Mapping
extension ProjectEntity {
    
    /// Convert ProjectEntity to ProjectLocal domain model
    func toLocal() -> ProjectLocal {
        ProjectLocal(
            id: projectId ?? UUID().uuidString,
            name: projectName ?? "",
            description: projectDescription,
            creatorName: creatorName,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date(),
            deletedAt: deletedAt,
            synced: synced
        )
    }
    
    /// Update ProjectEntity from ProjectLocal domain model
    func update(from local: ProjectLocal) {
        projectId = local.id
        projectName = local.name
        projectDescription = local.description
        creatorName = local.creatorName
        createdAt = local.createdAt
        updatedAt = local.updatedAt
        deletedAt = local.deletedAt
        synced = local.synced
    }
    
    /// Create ProjectEntity from ProjectLocal domain model
    static func create(from local: ProjectLocal, in context: NSManagedObjectContext) -> ProjectEntity {
        let entity = ProjectEntity(context: context)
        entity.update(from: local)
        return entity
    }
    
    /// Convert to ProjectRecord for network operations
    func toProjectRecord() -> ProjectRecord {
        ProjectRecord(
            project_id: projectId ?? "",
            project_name: projectName ?? "",
            creator_name: creatorName,
            description: projectDescription,
            created_at: DateFormatter.iso8601.string(from: createdAt ?? Date())
        )
    }
    
    /// Create ProjectRecord_write for network operations
    func toProjectRecordWrite() -> ProjectRecord_write {
        ProjectRecord_write(
            project_name: projectName ?? "",
            creator_name: creatorName ?? "",
            description: projectDescription,
            created_at: DateFormatter.iso8601.string(from: createdAt ?? Date())
        )
    }
    
    /// Get project statistics
    func getStatistics() -> ProjectLocal.Statistics {
        guard let scansSet = scans as? Set<ScanEntity> else {
            return ProjectLocal.Statistics.empty
        }
        
        let allScans = Array(scansSet)
        let activeScans = allScans.filter { $0.deletedAt == nil }
        let deletedScans = allScans.filter { $0.deletedAt != nil }
        let unsyncedScans = allScans.filter { !$0.synced }
        
        let lastScanDate = activeScans.compactMap { $0.scanTime }.max()
        
        // Calculate species frequency
        let speciesCount = Dictionary(grouping: activeScans) { $0.species ?? "Unknown" }
            .mapValues { $0.count }
        let mostCommonSpecies = speciesCount.max(by: { $0.value < $1.value })?.key
        
        // Calculate averages
        let heights = activeScans.map { $0.height }
        let diameters = activeScans.map { $0.diameter }
        let biomasses = activeScans.compactMap { $0.biomassEstimation > 0 ? $0.biomassEstimation : nil }
        
        let averageHeight = heights.isEmpty ? nil : heights.reduce(0, +) / Double(heights.count)
        let averageDiameter = diameters.isEmpty ? nil : diameters.reduce(0, +) / Double(diameters.count)
        let totalBiomass = biomasses.isEmpty ? nil : biomasses.reduce(0, +)
        
        return ProjectLocal.Statistics(
            totalScans: allScans.count,
            activeScanCount: activeScans.count,
            deletedScanCount: deletedScans.count,
            unsyncedScanCount: unsyncedScans.count,
            lastScanDate: lastScanDate,
            mostCommonSpecies: mostCommonSpecies,
            averageHeight: averageHeight,
            averageDiameter: averageDiameter,
            totalBiomass: totalBiomass
        )
    }
}

// MARK: - Fetch Request Extensions
extension ProjectEntity {
    
    /// Fetch request for active (non-deleted) projects
    static func activeProjectsFetchRequest() -> NSFetchRequest<ProjectEntity> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "deletedAt == nil")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ProjectEntity.updatedAt, ascending: false)]
        return request
    }
    
    /// Fetch request for unsynced projects
    static func unsyncedProjectsFetchRequest() -> NSFetchRequest<ProjectEntity> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "synced == NO")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ProjectEntity.updatedAt, ascending: true)]
        return request
    }
    
    /// Fetch request for projects by name (search)
    static func projectsFetchRequest(searchText: String) -> NSFetchRequest<ProjectEntity> {
        let request = activeProjectsFetchRequest()
        request.predicate = NSPredicate(
            format: "deletedAt == nil AND (projectName CONTAINS[cd] %@ OR projectDescription CONTAINS[cd] %@)",
            searchText, searchText
        )
        return request
    }
    
    /// Fetch request for projects by creator
    static func projectsFetchRequest(createdBy creator: String) -> NSFetchRequest<ProjectEntity> {
        let request = activeProjectsFetchRequest()
        request.predicate = NSPredicate(format: "deletedAt == nil AND creatorName == %@", creator)
        return request
    }
    
    /// Fetch request for a specific project by ID
    static func projectFetchRequest(id: String) -> NSFetchRequest<ProjectEntity> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "projectId == %@", id)
        request.fetchLimit = 1
        return request
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