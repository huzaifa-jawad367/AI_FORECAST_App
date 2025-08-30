//
//  ScanEntity.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 27/08/2025.
//

import Foundation
import CoreData

@objc(ScanEntity)
public class ScanEntity: NSManagedObject {
    
}

extension ScanEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ScanEntity> {
        return NSFetchRequest<ScanEntity>(entityName: "ScanEntity")
    }
    
    @NSManaged public var biomassEstimation: Double
    @NSManaged public var createdAt: Date?
    @NSManaged public var deletedAt: Date?
    @NSManaged public var diameter: Double
    @NSManaged public var height: Double
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var projectId: String?
    @NSManaged public var scanId: String?
    @NSManaged public var scanTime: Date?
    @NSManaged public var species: String?
    @NSManaged public var synced: Bool
    @NSManaged public var updatedAt: Date?
    @NSManaged public var userId: String?
    @NSManaged public var project: ProjectEntity?
}