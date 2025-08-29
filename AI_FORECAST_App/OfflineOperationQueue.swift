//
//  OfflineOperationQueue.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 27/08/2025.
//

import Foundation
import SwiftUI

enum OfflineOperation: String, Codable {
    case remoteSignOut = "remote_sign_out"
    case refreshTokens = "refresh_tokens"
    case syncData = "sync_data"
    
    var description: String {
        switch self {
        case .remoteSignOut:
            return "Remote Sign Out"
        case .refreshTokens:
            return "Refresh Tokens"
        case .syncData:
            return "Sync Data"
        }
    }
}

struct QueuedOperation: Codable {
    let id: UUID
    let type: OfflineOperation
    let timestamp: Date
    let retryCount: Int
    let maxRetries: Int
    let data: [String: String] // Additional data for the operation
    
    init(type: OfflineOperation, data: [String: String] = [:], maxRetries: Int = 3) {
        self.id = UUID()
        self.type = type
        self.timestamp = Date()
        self.retryCount = 0
        self.maxRetries = maxRetries
        self.data = data
    }
    
    var canRetry: Bool {
        return retryCount < maxRetries
    }
    
    var shouldRetry: Bool {
        // Don't retry if we've exceeded max retries
        guard canRetry else { return false }
        
        // Exponential backoff: wait longer between retries
        let baseDelay: TimeInterval = 5.0 // 5 seconds
        let exponentialDelay = baseDelay * pow(2.0, Double(retryCount))
        let timeSinceLastAttempt = Date().timeIntervalSince(timestamp)
        
        return timeSinceLastAttempt >= exponentialDelay
    }
}

@MainActor
class OfflineOperationQueue: ObservableObject {
    static let shared = OfflineOperationQueue()
    
    @Published var queuedOperations: [QueuedOperation] = []
    @Published var isProcessing: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let queueKey = "offline_operation_queue"
    private let networkMonitor = NetworkMonitor.shared
    
    private init() {
        loadQueuedOperations()
        setupNetworkMonitoring()
    }
    
    // MARK: - Queue Management
    
    /// Add an operation to the queue
    func queueOperation(_ operation: OfflineOperation, data: [String: String] = [:]) {
        let queuedOp = QueuedOperation(type: operation, data: data)
        queuedOperations.append(queuedOp)
        saveQueuedOperations()
        
        print("📋 Queued operation: \(operation.description)")
        
        // Try to process immediately if online
        if networkMonitor.isConnected {
            Task {
                await processQueuedOperations()
            }
        }
    }
    
    /// Process all queued operations
    func processQueuedOperations() async {
        guard !isProcessing else { return }
        guard networkMonitor.isConnected else { return }
        
        isProcessing = true
        print("🔄 Processing \(queuedOperations.count) queued operations...")
        
        var operationsToRemove: [UUID] = []
        
        for operation in queuedOperations {
            do {
                try await executeOperation(operation)
                operationsToRemove.append(operation.id)
                print("✅ Successfully executed: \(operation.type.description)")
            } catch {
                print("❌ Failed to execute \(operation.type.description): \(error.localizedDescription)")
                
                // Increment retry count - for now we'll just log the failure
                // TODO: Implement proper retry logic with exponential backoff
                print("⚠️ Operation failed, will retry later: \(operation.type.description)")
            }
        }
        
        // Remove successful operations
        queuedOperations.removeAll { operation in
            operationsToRemove.contains(operation.id)
        }
        
        saveQueuedOperations()
        isProcessing = false
        
        print("🏁 Finished processing queued operations. Remaining: \(queuedOperations.count)")
    }
    
    /// Execute a specific operation
    private func executeOperation(_ operation: QueuedOperation) async throws {
        switch operation.type {
        case .remoteSignOut:
            try await executeRemoteSignOut(operation)
        case .refreshTokens:
            try await executeRefreshTokens(operation)
        case .syncData:
            try await executeSyncData(operation)
        }
    }
    
    // MARK: - Operation Execution
    
    private func executeRemoteSignOut(_ operation: QueuedOperation) async throws {
        // This would typically call your Supabase client to sign out
        // For now, we'll simulate the operation
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        
        // Simulate potential failure
        if Bool.random() && operation.retryCount < 2 {
            throw NSError(domain: "OfflineOperationQueue", code: 1, userInfo: [NSLocalizedDescriptionKey: "Simulated network failure"])
        }
        
        print("✅ Remote sign out executed successfully")
    }
    
    private func executeRefreshTokens(_ operation: QueuedOperation) async throws {
        // This would refresh tokens using stored refresh token
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
        print("✅ Token refresh executed successfully")
    }
    
    private func executeSyncData(_ operation: QueuedOperation) async throws {
        // This would sync any pending data
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 second delay
        print("✅ Data sync executed successfully")
    }
    
    // MARK: - Network Monitoring
    
    private func setupNetworkMonitoring() {
        // Monitor network changes and process queue when back online
        networkMonitor.onConnectionChanged = { [weak self] isConnected in
            if isConnected {
                Task { @MainActor in
                    await self?.processQueuedOperations()
                }
            }
        }
    }
    
    // MARK: - Persistence
    
    private func saveQueuedOperations() {
        do {
            let data = try JSONEncoder().encode(queuedOperations)
            userDefaults.set(data, forKey: queueKey)
        } catch {
            print("❌ Failed to save queued operations: \(error.localizedDescription)")
        }
    }
    
    private func loadQueuedOperations() {
        guard let data = userDefaults.data(forKey: queueKey) else { return }
        
        do {
            queuedOperations = try JSONDecoder().decode([QueuedOperation].self, from: data)
            print("📋 Loaded \(queuedOperations.count) queued operations from storage")
        } catch {
            print("❌ Failed to load queued operations: \(error.localizedDescription)")
            queuedOperations = []
        }
    }
    
    // MARK: - Utility Methods
    
    /// Clear all queued operations
    func clearAllOperations() {
        queuedOperations.removeAll()
        saveQueuedOperations()
        print("🗑️ Cleared all queued operations")
    }
    
    /// Get operations of a specific type
    func getOperations(of type: OfflineOperation) -> [QueuedOperation] {
        return queuedOperations.filter { $0.type == type }
    }
    
    /// Check if there are any pending operations
    var hasPendingOperations: Bool {
        return !queuedOperations.isEmpty
    }
    
    /// Get a summary of queued operations
    var operationSummary: String {
        let counts = Dictionary(grouping: queuedOperations, by: { $0.type })
            .mapValues { $0.count }
        
        return counts.map { "\($0.key.description): \($0.value)" }.joined(separator: ", ")
    }
}
