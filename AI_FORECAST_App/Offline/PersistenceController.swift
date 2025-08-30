//
//  PersistenceController.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 27/08/2025.
//

import CoreData
import Foundation

@MainActor
final class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
    
    /// In-memory container for testing
    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        
        // Add sample data for previews
        let sampleProject = ProjectEntity(context: context)
        sampleProject.projectId = "preview-project-1"
        sampleProject.projectName = "Sample Forest Survey"
        sampleProject.projectDescription = "A preview project for UI testing"
        sampleProject.creatorName = "Preview User"
        sampleProject.createdAt = Date()
        sampleProject.updatedAt = Date()
        sampleProject.synced = false
        
        let sampleScan = ScanEntity(context: context)
        sampleScan.scanId = "preview-scan-1"
        sampleScan.height = 15.5
        sampleScan.diameter = 0.8
        sampleScan.species = "Oak"
        sampleScan.scanTime = Date()
        sampleScan.createdAt = Date()
        sampleScan.updatedAt = Date()
        sampleScan.synced = false
        sampleScan.project = sampleProject
        
        do {
            try context.save()
        } catch {
            print("Failed to save preview data: \(error)")
        }
        
        return controller
    }()
    
    let container: NSPersistentContainer
    
    /// Initialize the persistence controller
    /// - Parameter inMemory: Whether to use in-memory store (for testing)
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Biomass")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Configure SQLite store for production
            let storeDescription = container.persistentStoreDescriptions.first
            storeDescription?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            storeDescription?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        }
        
        container.loadPersistentStores { [weak self] _, error in
            if let error = error as NSError? {
                print("❌ Core Data error: \(error), \(error.userInfo)")
                fatalError("Unresolved Core Data error \(error), \(error.userInfo)")
            } else {
                print("✅ Core Data store loaded successfully")
            }
        }
        
        // Configure context for optimal performance
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    /// Save the main context with error handling
    func save() {
        let context = container.viewContext
        
        guard context.hasChanges else { return }
        
        do {
            try context.save()
            print("✅ Core Data context saved successfully")
        } catch {
            print("❌ Failed to save Core Data context: \(error)")
            // In production, you might want to handle this more gracefully
            // e.g., retry, user notification, crash reporting
        }
    }
    
    /// Perform a background task with a new context
    func performBackgroundTask<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            container.performBackgroundTask { context in
                do {
                    let result = try block(context)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Create a new background context for batch operations
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    /// Delete all data (useful for logout/reset)
    func deleteAllData() async throws {
        try await performBackgroundTask { context in
            // Delete all ScanEntity objects
            let scanRequest: NSFetchRequest<NSFetchRequestResult> = ScanEntity.fetchRequest()
            let scanDeleteRequest = NSBatchDeleteRequest(fetchRequest: scanRequest)
            try context.execute(scanDeleteRequest)
            
            // Delete all ProjectEntity objects
            let projectRequest: NSFetchRequest<NSFetchRequestResult> = ProjectEntity.fetchRequest()
            let projectDeleteRequest = NSBatchDeleteRequest(fetchRequest: projectRequest)
            try context.execute(projectDeleteRequest)
            
            try context.save()
        }
        
        await MainActor.run {
            save()
        }
    }
    
    /// Check if store is empty
    func isEmpty() async -> Bool {
        do {
            return try await performBackgroundTask { context in
                let scanRequest: NSFetchRequest<ScanEntity> = ScanEntity.fetchRequest()
                scanRequest.fetchLimit = 1
                
                let projectRequest: NSFetchRequest<ProjectEntity> = ProjectEntity.fetchRequest()
                projectRequest.fetchLimit = 1
                
                let scanCount = try context.count(for: scanRequest)
                let projectCount = try context.count(for: projectRequest)
                
                return scanCount == 0 && projectCount == 0
            }
        } catch {
            print("❌ Failed to check if store is empty: \(error)")
            return false
        }
    }
}

// MARK: - Error Types
enum PersistenceError: LocalizedError {
    case saveFailure(Error)
    case fetchFailure(Error)
    case entityNotFound
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .saveFailure(let error):
            return "Failed to save data: \(error.localizedDescription)"
        case .fetchFailure(let error):
            return "Failed to fetch data: \(error.localizedDescription)"
        case .entityNotFound:
            return "Entity not found"
        case .invalidData:
            return "Invalid data provided"
        }
    }
}
