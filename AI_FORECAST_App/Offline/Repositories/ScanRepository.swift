//
//  ScanRepository.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 27/08/2025.
//

import Foundation
import CoreData
import Combine

/// Repository for managing scan data with Core Data
@MainActor
final class ScanRepository: ObservableObject {
    private let persistenceController: PersistenceController
    private var cancellables = Set<AnyCancellable>()
    
    @Published var scans: [ScanLocal] = []
    @Published var isLoading = false
    @Published var error: PersistenceError?
    
    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }
    
    // MARK: - CRUD Operations
    
    /// Create a new scan
    func create(_ scan: ScanLocal) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await persistenceController.performBackgroundTask { context in
                _ = ScanEntity.create(from: scan, in: context)
                try context.save()
            }
            
            await refreshScans()
            print("✅ Scan created: \(scan.id)")
        } catch {
            self.error = .saveFailure(error)
            throw error
        }
    }
    
    /// Fetch all active scans
    func fetchAllScans() async throws -> [ScanLocal] {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let scanEntities = try await persistenceController.performBackgroundTask { context in
                let request = ScanEntity.activeScansFetchRequest()
                return try context.fetch(request)
            }
            
            let scans = scanEntities.map { $0.toLocal() }
            await MainActor.run {
                self.scans = scans
            }
            
            return scans
        } catch {
            self.error = .fetchFailure(error)
            throw error
        }
    }
    
    /// Fetch scans for a specific project
    func fetchScans(for projectId: String) async throws -> [ScanLocal] {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let scanEntities = try await persistenceController.performBackgroundTask { context in
                let request = ScanEntity.scansFetchRequest(for: projectId)
                return try context.fetch(request)
            }
            
            return scanEntities.map { $0.toLocal() }
        } catch {
            self.error = .fetchFailure(error)
            throw error
        }
    }
    
    /// Fetch a specific scan by ID
    func fetchScan(id: String) async throws -> ScanLocal? {
        do {
            let scanEntity = try await persistenceController.performBackgroundTask { context in
                let request = ScanEntity.fetchRequest()
                request.predicate = NSPredicate(format: "scanId == %@", id)
                request.fetchLimit = 1
                return try context.fetch(request).first
            }
            
            return scanEntity?.toLocal()
        } catch {
            self.error = .fetchFailure(error)
            throw error
        }
    }
    
    /// Update an existing scan
    func update(_ scan: ScanLocal) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let updated = try await persistenceController.performBackgroundTask { context in
                let request = ScanEntity.fetchRequest()
                request.predicate = NSPredicate(format: "scanId == %@", scan.id)
                request.fetchLimit = 1
                
                guard let entity = try context.fetch(request).first else {
                    throw PersistenceError.entityNotFound
                }
                
                entity.update(from: scan)
                try context.save()
                return entity.toLocal()
            }
            
            await refreshScans()
            print("✅ Scan updated: \(scan.id)")
        } catch {
            self.error = .saveFailure(error)
            throw error
        }
    }
    
    /// Delete a scan (soft delete)
    func delete(id: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await persistenceController.performBackgroundTask { context in
                let request = ScanEntity.fetchRequest()
                request.predicate = NSPredicate(format: "scanId == %@", id)
                request.fetchLimit = 1
                
                guard let entity = try context.fetch(request).first else {
                    throw PersistenceError.entityNotFound
                }
                
                entity.deletedAt = Date()
                entity.updatedAt = Date()
                try context.save()
            }
            
            await refreshScans()
            print("✅ Scan soft deleted: \(id)")
        } catch {
            self.error = .saveFailure(error)
            throw error
        }
    }
    
    /// Permanently delete a scan (hard delete)
    func permanentlyDelete(id: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await persistenceController.performBackgroundTask { context in
                let request = ScanEntity.fetchRequest()
                request.predicate = NSPredicate(format: "scanId == %@", id)
                request.fetchLimit = 1
                
                guard let entity = try context.fetch(request).first else {
                    throw PersistenceError.entityNotFound
                }
                
                context.delete(entity)
                try context.save()
            }
            
            await refreshScans()
            print("✅ Scan permanently deleted: \(id)")
        } catch {
            self.error = .saveFailure(error)
            throw error
        }
    }
    
    // MARK: - Specialized Queries
    
    /// Fetch scans by species
    func fetchScans(species: String) async throws -> [ScanLocal] {
        do {
            let scanEntities = try await persistenceController.performBackgroundTask { context in
                let request = ScanEntity.scansFetchRequest(for: species)
                return try context.fetch(request)
            }
            
            return scanEntities.map { $0.toLocal() }
        } catch {
            self.error = .fetchFailure(error)
            throw error
        }
    }
    
    /// Fetch unsynced scans
    func fetchUnsyncedScans() async throws -> [ScanLocal] {
        do {
            let scanEntities = try await persistenceController.performBackgroundTask { context in
                let request = ScanEntity.unsyncedScansFetchRequest()
                return try context.fetch(request)
            }
            
            return scanEntities.map { $0.toLocal() }
        } catch {
            self.error = .fetchFailure(error)
            throw error
        }
    }
    
    /// Mark scans as synced
    func markAsSynced(ids: [String]) async throws {
        do {
            try await persistenceController.performBackgroundTask { context in
                let request = ScanEntity.fetchRequest()
                request.predicate = NSPredicate(format: "scanId IN %@", ids)
                
                let entities = try context.fetch(request)
                for entity in entities {
                    entity.synced = true
                    entity.updatedAt = Date()
                }
                
                try context.save()
            }
            
            print("✅ Marked \(ids.count) scans as synced")
        } catch {
            self.error = .saveFailure(error)
            throw error
        }
    }
    
    /// Search scans by text (species, project name, etc.)
    func searchScans(text: String) async throws -> [ScanLocal] {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return await fetchAllScans()
        }
        
        do {
            let scanEntities = try await persistenceController.performBackgroundTask { context in
                let request = ScanEntity.activeScansFetchRequest()
                request.predicate = NSPredicate(
                    format: "deletedAt == nil AND species CONTAINS[cd] %@",
                    text
                )
                return try context.fetch(request)
            }
            
            return scanEntities.map { $0.toLocal() }
        } catch {
            self.error = .fetchFailure(error)
            throw error
        }
    }
    
    // MARK: - Statistics
    
    /// Get scan count for a project
    func getScanCount(for projectId: String) async throws -> Int {
        do {
            return try await persistenceController.performBackgroundTask { context in
                let request = ScanEntity.scansFetchRequest(for: projectId)
                return try context.count(for: request)
            }
        } catch {
            self.error = .fetchFailure(error)
            throw error
        }
    }
    
    /// Get total scan count
    func getTotalScanCount() async throws -> Int {
        do {
            return try await persistenceController.performBackgroundTask { context in
                let request = ScanEntity.activeScansFetchRequest()
                return try context.count(for: request)
            }
        } catch {
            self.error = .fetchFailure(error)
            throw error
        }
    }
    
    /// Get species distribution
    func getSpeciesDistribution() async throws -> [String: Int] {
        do {
            let scans = try await fetchAllScans()
            return Dictionary(grouping: scans) { $0.species }
                .mapValues { $0.count }
        } catch {
            throw error
        }
    }
    
    // MARK: - Helper Methods
    
    /// Refresh the published scans array
    private func refreshScans() async {
        do {
            _ = try await fetchAllScans()
        } catch {
            print("❌ Failed to refresh scans: \(error)")
        }
    }
    
    /// Clear all scans (for logout/reset)
    func clearAllScans() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await persistenceController.performBackgroundTask { context in
                let request: NSFetchRequest<NSFetchRequestResult> = ScanEntity.fetchRequest()
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
                try context.execute(deleteRequest)
                try context.save()
            }
            
            await MainActor.run {
                self.scans = []
            }
            
            print("✅ All scans cleared")
        } catch {
            self.error = .saveFailure(error)
            throw error
        }
    }
}

// MARK: - Batch Operations
extension ScanRepository {
    
    /// Create multiple scans in a batch
    func createBatch(_ scans: [ScanLocal]) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await persistenceController.performBackgroundTask { context in
                for scan in scans {
                    _ = ScanEntity.create(from: scan, in: context)
                }
                try context.save()
            }
            
            await refreshScans()
            print("✅ Created batch of \(scans.count) scans")
        } catch {
            self.error = .saveFailure(error)
            throw error
        }
    }
    
    /// Update multiple scans in a batch
    func updateBatch(_ scans: [ScanLocal]) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await persistenceController.performBackgroundTask { context in
                for scan in scans {
                    let request = ScanEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "scanId == %@", scan.id)
                    request.fetchLimit = 1
                    
                    if let entity = try context.fetch(request).first {
                        entity.update(from: scan)
                    }
                }
                try context.save()
            }
            
            await refreshScans()
            print("✅ Updated batch of \(scans.count) scans")
        } catch {
            self.error = .saveFailure(error)
            throw error
        }
    }
}
