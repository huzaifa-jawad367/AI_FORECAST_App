//
//  CustomARView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 09/10/2024.
//

//import ARKit
//import RealityKit
//import SwiftUI
//import Combine
//
//class CustomARView: ARView {
//    /// Tracks which marker to place next (0: trunk, 1: base, 2: top)
//    var markCount = 0
//
//    required init(frame frameRect: CGRect) {
//        super.init(frame: frameRect)
//
//        // 1) Take control of session configuration
//        self.automaticallyConfigureSession = false
//
//        // 2) Build and run a world‐tracking config with vertical plane detection
//        let config = ARWorldTrackingConfiguration()
//        config.planeDetection = [.vertical]
//        config.environmentTexturing = .automatic
//        self.session.run(config)
//
//        // 3) Install tap gesture handling
//        setupGestureRecognizers()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setupGestureRecognizers() {
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//        addGestureRecognizer(tapGesture)
//    }
//
//    /// Core logic for processing a tap at any screen point
//    func processTap(at screenLocation: CGPoint) {
//        // Raycast against estimated vertical surfaces
//        guard let result = self.raycast(
//                from: screenLocation,
//                allowing: .estimatedPlane,
//                alignment: .vertical
//              ).first
//        else { return }
//
//        // Extract world position
//        let worldPosition = SIMD3<Float>(
//            result.worldTransform.columns.3.x,
//            result.worldTransform.columns.3.y,
//            result.worldTransform.columns.3.z
//        )
//
//        // Decide which marker to place and store it
//        let markerType: MarkerType
//        switch markCount {
//        case 0:
//            markerType = .treeReference
//            ARManager.shared.referencePoint = worldPosition
//        case 1:
//            markerType = .base
//            ARManager.shared.bottomPoint = worldPosition
//        case 2:
//            markerType = .top
//            ARManager.shared.topPoint = worldPosition
//            calculateTreeHeight()
//        default:
//            return
//        }
//
//        // Visualize the marker and advance step
//        placeMarker(type: markerType, at: worldPosition)
//        markCount += 1
//    }
//
//    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
//        let location = sender.location(in: self)
//        processTap(at: location)
//    }
//
//    /// Simulate a tap at the center crosshair
//    func handleCenterTap() {
//        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        processTap(at: center)
//    }
//
//    /// Place a colored sphere at the given world position
//    func placeMarker(type: MarkerType, at position: SIMD3<Float>) {
//        let sphere = MeshResource.generateSphere(radius: 0.05)
//        let uiColor = UIColor(type.color)
//        let material = SimpleMaterial(color: uiColor, isMetallic: true)
//
//        let model = ModelEntity(mesh: sphere, materials: [material])
//        model.position = position
//
//        let anchor = AnchorEntity(world: position)
//        anchor.addChild(model)
//        scene.addAnchor(anchor)
//    }
//
//    /// Compute height between bottom & top points and show it
//    private func calculateTreeHeight() {
//        guard let height = ARManager.shared.calculateTreeHeight() else { return }
//        print("Tree Height: \(height) meters")
//        showAlert(
//            title: "Tree Height", message: "The tree height is \(height) meters."
//        )
//    }
//
//    /// Display a simple alert
//    private func showAlert(title: String, message: String) {
//        DispatchQueue.main.async {
//            let alert = UIAlertController(
//                title: title,
//                message: message,
//                preferredStyle: .alert
//            )
//            alert.addAction(.init(title: "OK", style: .default))
//            UIApplication.shared.windows.first?.rootViewController?
//                .present(alert, animated: true)
//        }
//    }
//}





import ARKit
import Combine
import SwiftUI
import RealityKit

class CustomARView: ARView {
    required init(frame frameRect: CGRect) {
        print("Required Init running")
        super.init(frame: frameRect)
        
    }
    
    dynamic required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // This is the init that we will actually use
    convenience init() {
        print("Convenience init running")
        self.init(frame: UIScreen.main.bounds)
        
        subscribeToActionStream()
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    func subscribeToActionStream() {
        print("Subscribing to steam")
        ARManager.shared
            .actionStream
            .sink { [weak self] action in
                switch action {
                    case .placeBlock(let color):
                        self?.placeBlock(ofColor: color)
                    case .placeSphere(let color):
                        self?.self .placeSphere(ofColor: color)
                    case .removeAllAnchors:
                        self?.scene.anchors.removeAll()
                }
            }
            .store(in: &cancellables)
    }
    
    func placeSphere(ofColor color: Color) {
        print("Placing sphere of color \(color)")
        // 1. Generate a sphere mesh with radius 0.25 m
        let sphere = MeshResource.generateSphere(radius: 0.2)
        // 2. Create a simple material from the SwiftUI Color
        let material = SimpleMaterial(color: UIColor(color), isMetallic: true)
        // 3. Build the ModelEntity
        let entity = ModelEntity(mesh: sphere, materials: [material])
        // 4. Anchor to the nearest horizontal plane
        let anchor = AnchorEntity(plane: .vertical)
        anchor.addChild(entity)
        // 5. Add it into the scene
        scene.addAnchor(anchor)
    }
    
    func placeBlock(ofColor color: Color) {
        print("Placing block of color \(color)")
        let block = MeshResource.generateBox(size: 0.2)
        let material = SimpleMaterial(color: UIColor(color), isMetallic: true)
        let entity = ModelEntity(mesh: block, materials: [material])
        
        let anchor = AnchorEntity(plane: .horizontal)
        anchor.addChild(entity)
        
        scene.addAnchor(anchor)
    }
}

