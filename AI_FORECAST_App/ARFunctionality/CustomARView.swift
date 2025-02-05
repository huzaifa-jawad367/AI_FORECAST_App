//
//  CustomARView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 09/10/2024.
//

import ARKit
import RealityKit
import SwiftUI

class CustomARView: ARView {
    var markCount = 0

    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        setupGestureRecognizers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self)
        if let result = raycast(from: location, allowing: .estimatedPlane, alignment: .vertical).first {
            // Correct way to extract position from worldTransform
            let worldPosition = SIMD3<Float>(result.worldTransform.columns.3.x,
                                             result.worldTransform.columns.3.y,
                                             result.worldTransform.columns.3.z)
            
            placeMarker(at: worldPosition)
            
            switch markCount {
            case 0:
                ARManager.shared.referencePoint = worldPosition
                print("Reference point marked at: \(worldPosition)")
            case 1:
                ARManager.shared.bottomPoint = worldPosition
                print("Bottom point marked at: \(worldPosition)")
            case 2:
                ARManager.shared.topPoint = worldPosition
                print("Top point marked at: \(worldPosition)")
                calculateTreeHeight()
            default:
                return
            }
            markCount += 1
        }
    }

    func placeMarker(at position: SIMD3<Float>) {
        let sphere = MeshResource.generateSphere(radius: 0.05)
        let material = SimpleMaterial(color: .red, isMetallic: true)
        let model = ModelEntity(mesh: sphere, materials: [material])
        model.position = position

        let anchor = AnchorEntity(world: position)
        anchor.addChild(model)
        scene.addAnchor(anchor)
    }

    func calculateTreeHeight() {
        if let height = ARManager.shared.calculateTreeHeight() {
            print("Tree Height: \(height) meters")
            showAlert(title: "Tree Height", message: "The tree height is \(String(format: "%.2f", height)) meters.")
        }
    }

    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            if let viewController = UIApplication.shared.windows.first?.rootViewController {
                viewController.present(alert, animated: true)
            }
        }
    }
}

