//
//  NetworkMonitor.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 27/08/2025.
//

import Foundation
import Network
import SwiftUI

@MainActor
class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    @Published var isConnected: Bool = false
    @Published var connectionType: ConnectionType = .unknown
    
    var onConnectionChanged: ((Bool) -> Void)?
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
        
        var description: String {
            switch self {
            case .wifi:
                return "WiFi"
            case .cellular:
                return "Cellular"
            case .ethernet:
                return "Ethernet"
            case .unknown:
                return "Unknown"
            }
        }
    }
    
    private init() {
        startMonitoring()
    }
    
    deinit {
        Task { @MainActor in
            stopMonitoring()
        }
    }
    
    // MARK: - Network Monitoring
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.updateConnectionStatus(path)
            }
        }
        
        monitor.start(queue: queue)
    }
    
    private func stopMonitoring() {
        monitor.cancel()
    }
    
    private func updateConnectionStatus(_ path: NWPath) {
        let wasConnected = isConnected
        let wasConnectionType = connectionType
        
        // Update connection status
        isConnected = path.status == .satisfied
        
        // Update connection type
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
        
        // Notify if connection status changed
        if wasConnected != isConnected || wasConnectionType != connectionType {
            print("🌐 Network status changed: \(isConnected ? "Connected" : "Disconnected") via \(connectionType.description)")
            onConnectionChanged?(isConnected)
        }
    }
    
    // MARK: - Utility Methods
    
    /// Check if we have a specific type of connection
    func hasConnection(of type: ConnectionType) -> Bool {
        return isConnected && connectionType == type
    }
    
    /// Get connection status description
    var connectionStatusDescription: String {
        if isConnected {
            return "Connected via \(connectionType.description)"
        } else {
            return "No internet connection"
        }
    }
    
    /// Check if we have a reliable connection (WiFi or Ethernet)
    var hasReliableConnection: Bool {
        return isConnected && (connectionType == .wifi || connectionType == .ethernet)
    }
    
    /// Check if we have a cellular connection
    var hasCellularConnection: Bool {
        return isConnected && connectionType == .cellular
    }
}
