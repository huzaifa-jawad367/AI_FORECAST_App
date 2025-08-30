//
//  ProjectEntity.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 27/08/2025.
//

import Foundation
import CoreData

@objc(ProjectEntity)
public class ProjectEntity: NSManagedObject {
    
}

extension ProjectEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProjectEntity> {
        return NSFetchRequest<ProjectEntity>(entityName: "ProjectEntity")
    }
    
    @NSManaged public var createdAt: Date?
    @NSManaged public var creatorName: String?
    @NSManaged public var deletedAt: Date?
    @NSManaged public var projectDescription: String?
    @NSManaged public var projectId: String?
    @NSManaged public var projectName: String?
    @NSManaged public var synced: Bool
    @NSManaged public var updatedAt: Date?
    @NSManaged public var scans: NSSet?
}

// MARK: Generated accessors for scans
extension ProjectEntity {
    
    @objc(addScansObject:)
    @NSManaged public func addToScans(_ value: ScanEntity)
    
    @objc(removeScansObject:)
    @NSManaged public func removeFromScans(_ value: ScanEntity)
    
    @objc(addScans:)
    @NSManaged public func addToScans(_ values: NSSet)
    
    @objc(removeScans:)
    @NSManaged public func removeFromScans(_ values: NSSet)
}
