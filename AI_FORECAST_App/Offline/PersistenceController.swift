//
//  PersistenceController.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 27/08/2025.
//

import CoreData
import Foundation

final class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
    
    // Track store loading completion
    private var storesLoaded = false
    private var storeLoadingTask: Task<Void, Never>?
    private var isLoadingStores = false
    
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
        
        isLoadingStores = true
        storeLoadingTask = Task { @MainActor in
            await withCheckedContinuation { continuation in
                print("[CD] 🔄 Starting to load persistent stores...")
                print("[CD] 📁 Store description: \(container.persistentStoreDescriptions.first?.url?.absoluteString ?? "nil")")
                print("[CD] 📦 Model entities: \(container.managedObjectModel.entities.map { $0.name ?? "unnamed" })")
                print("[CD] 🔧 Container name: \(container.name)")
                print("[CD] 🔧 Container model: \(container.managedObjectModel)")
                
                container.loadPersistentStores { _, error in
                    Task { @MainActor in
                        self.isLoadingStores = false
                        if let error = error as NSError? {
                            print("[CD] ❌ Core Data error: \(error), \(error.userInfo)")
                            print("[CD] ❌ Error domain: \(error.domain), code: \(error.code)")
                            print("[CD] ❌ Error description: \(error.localizedDescription)")
                            print("[CD] ❌ Error debug description: \(error.debugDescription)")
                            // Don't fatal error, just log and continue
                            print("[CD] ⚠️ Core Data store loading failed, will use emergency store")
                        } else {
                            print("[CD] ✅ Core Data store loaded successfully")
                            print("[CD] 📊 Final store count: \(self.container.persistentStoreCoordinator.persistentStores.count)")
                            self.storesLoaded = true
                        }
                    }
                    continuation.resume()
                }
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
    
    /// Ensure stores are loaded before proceeding
    private func ensureStoresLoaded() async {
        await MainActor.run {
            let loaded = !container.persistentStoreCoordinator.persistentStores.isEmpty || storesLoaded
            if loaded {
                print("[CD] ✅ Stores already loaded")
                return
            }
            
            if isLoadingStores {
                print("[CD] ⏳ Stores are currently loading, waiting for completion...")
            } else {
                print("[CD] ⏳ No stores loaded and none loading, waiting for initial load...")
            }
        }
        
        // Wait up to 5s for storesLoaded to flip true
        let deadline = Date().addingTimeInterval(5)
        while true {
            let done = await MainActor.run { self.storesLoaded || !self.container.persistentStoreCoordinator.persistentStores.isEmpty }
            if done { break }
            if Date() >= deadline { break }
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        }
        
        await MainActor.run {
            let finalCount = container.persistentStoreCoordinator.persistentStores.count
            print("[CD] ✅ ensureStoresLoaded: finished with \(finalCount) stores")
            if finalCount == 0 && !storesLoaded {
                print("[CD] ❌ ensureStoresLoaded timeout: persistent stores not loaded after waiting")
            }
        }
    }
    
    /// Perform a background task with a new context
    func performBackgroundTask<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        // Ensure stores are loaded first
        await ensureStoresLoaded()
        print("Checking is the error is in ensureStoresLoaded")
        
        // If still no stores, try to create a minimal working store
        let isEmpty = await MainActor.run { container.persistentStoreCoordinator.persistentStores.isEmpty }
        if isEmpty {
            print("[CD] 🚨 No stores available, attempting emergency store creation...")
            await createEmergencyStore()
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let operationId = UUID().uuidString
            let queueLabel = String(cString: __dispatch_queue_get_label(nil))
            let isMain = Thread.isMainThread
            let startTime = CFAbsoluteTimeGetCurrent()
            print("[CD] ▶️ performBackgroundTask start id=\(operationId) main=\(isMain) queue=\(queueLabel)")

            // Use a simple flag with proper synchronization
            var hasResumed = false
            let resumeLock = NSLock()

            // Timeout detector to surface potential leaks
            DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                resumeLock.lock()
                let shouldLog = !hasResumed
                resumeLock.unlock()
                
                if shouldLog {
                    let elapsed = String(format: "%.3f", CFAbsoluteTimeGetCurrent() - startTime)
                    print("[CD] ⚠️ performBackgroundTask id=\(operationId) has not resumed after \(elapsed)s. Possible continuation leak.")
                    print("[CD] ⚠️ Call stack (might help):\n\(Thread.callStackSymbols.joined(separator: "\n"))")
                }
            }

            // Prefer a dedicated background context to avoid potential scheduling issues
            let context = self.container.newBackgroundContext()
            let concurrency: String = {
                switch context.concurrencyType {
                case .confinementConcurrencyType: return "confinement"
                case .privateQueueConcurrencyType: return "private"
                case .mainQueueConcurrencyType: return "main"
                @unknown default: return "unknown"
                }
            }()
            print("[CD] 🧵 created background context id=\(operationId) ctx=\(Unmanaged.passUnretained(context).toOpaque()) concurrency=\(concurrency)")

            // Check store status after ensuring they're loaded
            let storeCount = self.container.persistentStoreCoordinator.persistentStores.count
            print("[CD] 📊 Store count: \(storeCount) at call time id=\(operationId)")
            if storeCount == 0 {
                print("[CD] ❗ No persistent stores loaded at call time id=\(operationId). Operations may stall.")
                // Try to resume with an error instead of hanging
                resumeLock.lock()
                if !hasResumed {
                    hasResumed = true
                    resumeLock.unlock()
                    print("[CD] 🔚 resuming continuation (failure) due to no stores id=\(operationId)")
                    continuation.resume(throwing: PersistenceError.invalidData)
                    return
                }
                resumeLock.unlock()
            }

            context.perform {
                print("[CD] 🛠️ executing user block on context queue id=\(operationId)")
                do {
                    let result = try block(context)
                    print("[CD] ✅ user block completed id=\(operationId)")
                    
                    resumeLock.lock()
                    if !hasResumed {
                        hasResumed = true
                        resumeLock.unlock()
                        print("[CD] 🔚 resuming continuation (success) id=\(operationId) elapsed=\(String(format: "%.3f", CFAbsoluteTimeGetCurrent() - startTime))s")
                        continuation.resume(returning: result)
                    } else {
                        resumeLock.unlock()
                        print("[CD] ❗ attempt to resume after already resumed (success) id=\(operationId)")
                    }
                } catch {
                    print("[CD] ❌ user block threw id=\(operationId) error=\(error)")
                    
                    resumeLock.lock()
                    if !hasResumed {
                        hasResumed = true
                        resumeLock.unlock()
                        print("[CD] 🔚 resuming continuation (failure) id=\(operationId) elapsed=\(String(format: "%.3f", CFAbsoluteTimeGetCurrent() - startTime))s")
                        continuation.resume(throwing: error)
                    } else {
                        resumeLock.unlock()
                        print("[CD] ❗ attempt to resume after already resumed (failure) id=\(operationId)")
                    }
                }
            }
        }
    }
    
    /// Create an emergency store if none exist
    private func createEmergencyStore() async {
        print("[CD] 🚨 Creating emergency in-memory store...")
        
        await MainActor.run {
            // Remove any existing stores
            for store in container.persistentStoreCoordinator.persistentStores {
                try? container.persistentStoreCoordinator.remove(store)
            }
            
            // Create an in-memory store as fallback
            let storeDescription = NSPersistentStoreDescription()
            storeDescription.type = NSInMemoryStoreType
            storeDescription.url = URL(fileURLWithPath: "/dev/null")
            
            container.persistentStoreDescriptions = [storeDescription]
        }
        
        await withCheckedContinuation { continuation in
            var hasResumed = false
            
            // Add a timeout to prevent hanging
            DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                if !hasResumed {
                    hasResumed = true
                    print("[CD] ⚠️ Emergency store creation timed out, resuming continuation")
                    continuation.resume()
                }
            }
            
            // Try to add the store directly to the coordinator
            do {
                let store = try container.persistentStoreCoordinator.addPersistentStore(
                    ofType: NSInMemoryStoreType,
                    configurationName: nil,
                    at: URL(fileURLWithPath: "/dev/null"),
                    options: nil
                )
                print("[CD] ✅ Emergency store added successfully: \(store)")
                if !hasResumed {
                    hasResumed = true
                    Task { @MainActor in
                        self.storesLoaded = true
                        continuation.resume()
                    }
                }
            } catch {
                print("[CD] ❌ Failed to add emergency store directly: \(error)")
                // Fallback to loadPersistentStores
                container.loadPersistentStores { _, error in
                    if !hasResumed {
                        hasResumed = true
                        Task { @MainActor in
                            if let error = error {
                                print("[CD] ❌ Emergency store creation failed: \(error)")
                            } else {
                                print("[CD] ✅ Emergency store created successfully via loadPersistentStores")
                                self.storesLoaded = true
                            }
                            continuation.resume()
                        }
                    }
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
