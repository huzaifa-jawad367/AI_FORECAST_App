//
//  ScanEntity+Mapping.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 27/08/2025.
//

import Foundation
import CoreData

// MARK: - ScanEntity Core Data Mapping
extension ScanEntity {
    
    /// Convert ScanEntity to ScanLocal domain model
    func toLocal() -> ScanLocal {
        let coordinate: TreeCoordinate?
        if let lat = latitude as? Double, let lon = longitude as? Double,
           lat != 0 || lon != 0 {
            coordinate = TreeCoordinate(latitude: lat, longitude: lon)
        } else {
            coordinate = nil
        }
        
        return ScanLocal(
            id: scanId ?? UUID().uuidString,
            height: height,
            diameter: diameter,
            species: species ?? "",
            scanTime: scanTime ?? Date(),
            projectId: projectId,
            userId: userId,
            coordinate: coordinate,
            biomassEstimation: biomassEstimation > 0 ? biomassEstimation : nil,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date(),
            deletedAt: deletedAt,
            synced: synced
        )
    }
    
    /// Update ScanEntity from ScanLocal domain model
    func update(from local: ScanLocal) {
        scanId = local.id
        height = local.height
        diameter = local.diameter
        species = local.species
        scanTime = local.scanTime
        projectId = local.projectId
        userId = local.userId
        
        // Handle coordinates
        if let coord = local.coordinate {
            latitude = coord.latitude
            longitude = coord.longitude
        } else {
            latitude = 0
            longitude = 0
        }
        
        biomassEstimation = local.biomassEstimation ?? 0
        createdAt = local.createdAt
        updatedAt = local.updatedAt
        deletedAt = local.deletedAt
        synced = local.synced
    }
    
    /// Create ScanEntity from ScanLocal domain model
    static func create(from local: ScanLocal, in context: NSManagedObjectContext) -> ScanEntity {
        let entity = ScanEntity(context: context)
        entity.update(from: local)
        return entity
    }
    
    /// Convert to ScanRecord for network operations
    func toScanRecord() -> ScanRecord {
        ScanRecord(
            scan_id: scanId ?? "",
            height: height,
            diameter: diameter,
            species: species ?? "",
            scan_time: DateFormatter.iso8601.string(from: scanTime ?? Date()),
            project_name: project?.projectName, // Accessed via relationship
            user_name: nil, // Would need user data
            biomass_estimation: biomassEstimation > 0 ? Float(biomassEstimation) : nil,
            latitude: latitude != 0 ? Float(latitude) : nil,
            longitude: longitude != 0 ? Float(longitude) : nil
        )
    }
    
    /// Create ScanRecord_write for network operations
    func toScanRecordWrite() -> ScanRecord_write {
        ScanRecord_write(
            height: height,
            diameter: diameter,
            species: species ?? "",
            scan_time: DateFormatter.iso8601.string(from: scanTime ?? Date()),
            project_id: projectId ?? "",
            user_id: userId ?? "",
            biomass_estimation: biomassEstimation,
            latitude: Float(latitude),
            longitude: Float(longitude)
        )
    }
}

// MARK: - Fetch Request Extensions
extension ScanEntity {
    
    // /// Create a fetch request for all scans
    // @nonobjc public class func fetchRequest() -> NSFetchRequest<ScanEntity> {
    //     return NSFetchRequest<ScanEntity>(entityName: "ScanEntity")
    // }
    
    /// Fetch request for active (non-deleted) scans
    static func activeScansFetchRequest() -> NSFetchRequest<ScanEntity> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "deletedAt == nil")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ScanEntity.scanTime, ascending: false)]
        return request
    }
    
    /// Fetch request for scans in a specific project - ✅ RENAMED
    static func scansInProjectFetchRequest(projectId: String) -> NSFetchRequest<ScanEntity> {
        let request = activeScansFetchRequest()
        request.predicate = NSPredicate(format: "deletedAt == nil AND projectId == %@", projectId)
        return request
    }
    
    /// Fetch request for unsynced scans
    static func unsyncedScansFetchRequest() -> NSFetchRequest<ScanEntity> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "synced == NO")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ScanEntity.updatedAt, ascending: true)]
        return request
    }
    
    /// Fetch request for scans by species - ✅ RENAMED
    static func scansBySpeciesFetchRequest(species: String) -> NSFetchRequest<ScanEntity> {
        let request = activeScansFetchRequest()
        request.predicate = NSPredicate(format: "deletedAt == nil AND species CONTAINS[cd] %@", species)
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