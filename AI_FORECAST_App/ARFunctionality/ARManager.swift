//
//  ARManager.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 17/10/2024.
//

import Combine
import RealityKit

class ARManager {
    static let shared = ARManager()
    private init() {}

    /// Event bus for AR commands & events
    let actionStream = PassthroughSubject<ARAction, Never>()
    
    /// Stored world‑space points
    var referencePoint: SIMD3<Float>?
    var bottomPoint:    SIMD3<Float>?
    var topPoint:       SIMD3<Float>?
    
    /// Compute Euclidean distance between bottom & top
    func calculateTreeHeight() -> Float? {
        guard let b = bottomPoint, let t = topPoint else { return nil }
        return simd_distance(b, t)
    }
    
    /// Clear all stored points
    func resetPoints() {
        referencePoint = nil
        bottomPoint    = nil
        topPoint       = nil
    }
}

