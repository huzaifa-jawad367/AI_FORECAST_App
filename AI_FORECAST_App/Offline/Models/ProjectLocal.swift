//
//  ProjectLocal.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 27/08/2025.
//

import Foundation

/// Local domain model for project data
struct ProjectLocal: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let description: String?
    let creatorName: String?
    
    // Metadata
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    let synced: Bool
    
    /// Initialize a new project with current timestamp
    init(
        id: String = UUID().uuidString,
        name: String,
        description: String? = nil,
        creatorName: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        deletedAt: Date? = nil,
        synced: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.creatorName = creatorName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.synced = synced
    }
    
    /// Create a copy with updated fields
    func updated(
        name: String? = nil,
        description: String? = nil,
        creatorName: String? = nil,
        deletedAt: Date? = nil,
        synced: Bool? = nil
    ) -> ProjectLocal {
        ProjectLocal(
            id: self.id,
            name: name ?? self.name,
            description: description ?? self.description,
            creatorName: creatorName ?? self.creatorName,
            createdAt: self.createdAt,
            updatedAt: Date(),
            deletedAt: deletedAt ?? self.deletedAt,
            synced: synced ?? self.synced
        )
    }
    
    /// Mark as deleted (soft delete)
    func markDeleted() -> ProjectLocal {
        updated(deletedAt: Date())
    }
    
    /// Mark as synced with server
    func markSynced() -> ProjectLocal {
        updated(synced: true)
    }
    
    /// Check if project is deleted
    var isDeleted: Bool {
        deletedAt != nil
    }
    
    /// Check if project needs sync
    var needsSync: Bool {
        !synced
    }
    
    /// Display name for the project (fallback to ID if name is empty)
    var displayName: String {
        name.isEmpty ? "Project \(id.prefix(8))" : name
    }
    
    /// Short description for UI
    var shortDescription: String {
        if let desc = description, !desc.isEmpty {
            return desc.count > 100 ? String(desc.prefix(97)) + "..." : desc
        }
        return "No description"
    }
}

// MARK: - Validation
extension ProjectLocal {
    /// Validate project data
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Get validation errors
    var validationErrors: [String] {
        var errors: [String] = []
        
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Project name cannot be empty")
        }
        
        return errors
    }
}

// MARK: - Codable (for JSON serialization if needed)
extension ProjectLocal: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, description, creatorName
        case createdAt, updatedAt, deletedAt, synced
    }
}

// MARK: - Statistics
extension ProjectLocal {
    /// Statistics about the project (would be calculated by repository)
    struct Statistics {
        let totalScans: Int
        let activeScanCount: Int
        let deletedScanCount: Int
        let unsyncedScanCount: Int
        let lastScanDate: Date?
        let mostCommonSpecies: String?
        let averageHeight: Double?
        let averageDiameter: Double?
        let totalBiomass: Double?
        
        static let empty = Statistics(
            totalScans: 0,
            activeScanCount: 0,
            deletedScanCount: 0,
            unsyncedScanCount: 0,
            lastScanDate: nil,
            mostCommonSpecies: nil,
            averageHeight: nil,
            averageDiameter: nil,
            totalBiomass: nil
        )
    }
}
