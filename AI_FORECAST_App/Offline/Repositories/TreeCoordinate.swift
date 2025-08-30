//
//  TreeCoordinate.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 27/08/2025.
//

import Foundation
import CoreLocation

/// A value type representing geographic coordinates for tree locations
struct TreeCoordinate: Codable, Equatable, Hashable {
    let latitude: Double
    let longitude: Double
    
    /// Initialize with lat/lon values
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    /// Initialize from CoreLocation coordinate
    init(_ coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    /// Convert to CoreLocation coordinate
    var clLocationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    /// Check if coordinates are valid
    var isValid: Bool {
        latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180
    }
    
    /// Calculate distance to another coordinate in meters
    func distance(to other: TreeCoordinate) -> Double {
        let location1 = CLLocation(latitude: latitude, longitude: longitude)
        let location2 = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return location1.distance(from: location2)
    }
    
    /// Format coordinates for display
    var displayString: String {
        String(format: "%.6f, %.6f", latitude, longitude)
    }
    
    /// Zero coordinate (useful for default values)
    static let zero = TreeCoordinate(latitude: 0, longitude: 0)
}

// MARK: - CustomStringConvertible
extension TreeCoordinate: CustomStringConvertible {
    var description: String {
        "TreeCoordinate(lat: \(latitude), lon: \(longitude))"
    }
}
