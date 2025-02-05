//
//  ARManager.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 17/10/2024.
//

import Combine
import RealityKit
import ARKit

class ARManager {
    static let shared = ARManager()
    private init() { }

    var referencePoint: SIMD3<Float>?
    var bottomPoint: SIMD3<Float>?
    var topPoint: SIMD3<Float>?
    
    func calculateTreeHeight() -> Float? {
        guard let bottom = bottomPoint, let top = topPoint else {
            return nil
        }
        return simd_distance(bottom, top)
    }
}

