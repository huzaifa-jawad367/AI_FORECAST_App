//
//  ScanLocal.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 27/08/2025.
//

import Foundation

/// Local domain model for tree scan data
struct ScanLocal: Identifiable, Equatable, Hashable {
    let id: String
    let height: Double
    let diameter: Double
    let species: String
    let scanTime: Date
    let projectId: String?
    let userId: String?
    
    // Location data
    let coordinate: TreeCoordinate?
    
    // Biomass estimation
    let biomassEstimation: Double?
    
    // Metadata
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    let synced: Bool
    
    /// Initialize a new scan with current timestamp
    init(
        id: String = UUID().uuidString,
        height: Double,
        diameter: Double,
        species: String,
        scanTime: Date = Date(),
        projectId: String? = nil,
        userId: String? = nil,
        coordinate: TreeCoordinate? = nil,
        biomassEstimation: Double? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        deletedAt: Date? = nil,
        synced: Bool = false
    ) {
        self.id = id
        self.height = height
        self.diameter = diameter
        self.species = species
        self.scanTime = scanTime
        self.projectId = projectId
        self.userId = userId
        self.coordinate = coordinate
        self.biomassEstimation = biomassEstimation
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.synced = synced
    }
    
    /// Create a copy with updated fields
    func updated(
        height: Double? = nil,
        diameter: Double? = nil,
        species: String? = nil,
        scanTime: Date? = nil,
        projectId: String? = nil,
        userId: String? = nil,
        coordinate: TreeCoordinate? = nil,
        biomassEstimation: Double? = nil,
        deletedAt: Date? = nil,
        synced: Bool? = nil
    ) -> ScanLocal {
        ScanLocal(
            id: self.id,
            height: height ?? self.height,
            diameter: diameter ?? self.diameter,
            species: species ?? self.species,
            scanTime: scanTime ?? self.scanTime,
            projectId: projectId ?? self.projectId,
            userId: userId ?? self.userId,
            coordinate: coordinate ?? self.coordinate,
            biomassEstimation: biomassEstimation ?? self.biomassEstimation,
            createdAt: self.createdAt,
            updatedAt: Date(),
            deletedAt: deletedAt ?? self.deletedAt,
            synced: synced ?? self.synced
        )
    }
    
    /// Mark as deleted (soft delete)
    func markDeleted() -> ScanLocal {
        updated(deletedAt: Date())
    }
    
    /// Mark as synced with server
    func markSynced() -> ScanLocal {
        updated(synced: true)
    }
    
    /// Check if scan is deleted
    var isDeleted: Bool {
        deletedAt != nil
    }
    
    /// Check if scan needs sync
    var needsSync: Bool {
        !synced
    }
    
    /// Calculate tree volume (simplified cylinder formula)
    var estimatedVolume: Double {
        let radiusMeters = diameter / 2
        return Double.pi * radiusMeters * radiusMeters * height
    }
    
    /// Check if scan has location data
    var hasLocation: Bool {
        coordinate?.isValid == true
    }
    
    /// Display name for the scan
    var displayName: String {
        "\(species) - \(String(format: "%.1f", height))m"
    }
}

// MARK: - Validation
extension ScanLocal {
    /// Validate scan data
    var isValid: Bool {
        height > 0 &&
        diameter > 0 &&
        !species.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (coordinate?.isValid ?? true) // Coordinate is valid if present
    }
    
    /// Get validation errors
    var validationErrors: [String] {
        var errors: [String] = []
        
        if height <= 0 {
            errors.append("Height must be greater than 0")
        }
        
        if diameter <= 0 {
            errors.append("Diameter must be greater than 0")
        }
        
        if species.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Species cannot be empty")
        }
        
        if let coord = coordinate, !coord.isValid {
            errors.append("Invalid coordinates")
        }
        
        return errors
    }
}

// MARK: - Codable (for JSON serialization if needed)
extension ScanLocal: Codable {
    enum CodingKeys: String, CodingKey {
        case id, height, diameter, species, scanTime
        case projectId, userId, coordinate, biomassEstimation
        case createdAt, updatedAt, deletedAt, synced
    }
}