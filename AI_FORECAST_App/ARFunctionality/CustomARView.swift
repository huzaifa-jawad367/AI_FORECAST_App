//
//  CustomARView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 09/10/2024.
//


import ARKit
import Combine
import SwiftUI
import RealityKit

extension ARView {
    /// Disables all plane detection on the running session
    func disablePlaneDetection() {
        guard let worldConfig = session.configuration as? ARWorldTrackingConfiguration else {
            return
        }
        worldConfig.planeDetection = []                       // no more planes
        session.run(worldConfig)                              // re‑run with updated config
        print("Plane detection disabled")
    }
}

extension ARView {
  /// Turn vertical plane detection back on
  func enablePlaneDetection() {
    guard let cfg = session.configuration as? ARWorldTrackingConfiguration else { return }
    cfg.planeDetection = [.vertical]
    session.run(cfg, options: [])
    print("Plane detection re‑enabled")
  }
}


class CustomARView: ARView {
    
    private var markCount = 0
    private var cancellables: Set<AnyCancellable> = []
    private var trackedRaycasts: [ARTrackedRaycast] = []
    
    required init(frame frameRect: CGRect) {
        print("Required Init running")
        super.init(frame: frameRect)
        
        // 1) Configure session to detect vertical planes at first
        automaticallyConfigureSession = false
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.vertical]
        session.run(config)
        print("AR session started with vertical plane detection")
        
        // 3) Turn on the two debug overlays:
        //    • showAnchorGeometry draws a wireframe over every detected plane anchor.
        //    • showFeaturePoints draws ARKit’s raw feature-point cloud.
        debugOptions.insert(.showAnchorGeometry)
        debugOptions.insert(.showFeaturePoints)
    }
    
    // This is only needed if you instantiate from a Storyboard or XIB
    @available(*, unavailable)
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // If you’re using SwiftUI or manually creating it without a frame:
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
        subscribeToActionStream()
    }
    
    func subscribeToActionStream() {
        print("Subscribing to steam")
        ARManager.shared
            .actionStream
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                guard let self = self else { return }
                switch action {
                    case .placeNextTreeMarker:
                        self.placeNextTreeMarker()
                    case .placeBlock(let color):
                        self.placeBlock(ofColor: color)
//                    case .placeTopMarker:
//                        self.placeTopMarker()
                    case .removeAllAnchors:
                        self.scene.anchors.removeAll()
                        self.markCount = 0
                        self.enablePlaneDetection()
                    case .placeSphere(let color):
                        self.placeSphere(at: .zero, color: color)
                    case .showHeight(let height):
                        // You could pop an in-AR UI, or simply log it here.
                        print("ARAction.showHeight(\(height)) received")
                }
            }
            .store(in: &cancellables)
    }
    
    /// **LEGACY**
    /// 2) Raycast any surface to place bottom anchor
//    private func placeBottomMarker() {
//        guard let worldPos = raycastSurface(alignment: .any) else { return }
//        ARManager.shared.bottomPoint = worldPos
//        placeSphere(at: worldPos, color: .red)
//        print("Bottom marker at \(worldPos)")
//    }

    /// **LEGACY**
    /// 3) Raycast any surface to place top anchor and compute height
//    private func placeTopMarker() {
//        guard let worldPos = raycastSurface(alignment: .any) else { return }
//        ARManager.shared.topPoint = worldPos
//        placeSphere(at: worldPos, color: .red)
//        print("Top marker at \(worldPos)")
//        if let height = ARManager.shared.calculateTreeHeight() {
//            print(String(format: "Tree height: %.2f m", height))
//        }
//    }

    // MARK: - Raycast Helper
    /// Performs a raycast from screen center, returns first hit world position
    private func raycastSurface(alignment: ARRaycastQuery.TargetAlignment) -> SIMD3<Float>? {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        guard let result = self.raycast(from: center,
//                                        allowing: .estimatedPlane,
//                                        alignment: alignment).first
        guard let result = self.raycast(from: center,
                                        allowing: .existingPlaneInfinite,
                                        alignment: alignment).first
        else {
            print("Raycast failed for alignment \(alignment)")
            return nil
        }
        let t = result.worldTransform.columns.3
        return SIMD3<Float>(t.x, t.y, t.z)
    }
    
    func placeTrunkMarker() {
      print("▶ placeTrunkMarker() called")
      
      guard let query = makeRaycastQuery(
              from: CGPoint(x: bounds.midX, y: bounds.midY),
              allowing: .estimatedPlane,
              alignment: .vertical)
      else {
        print("  ✖ Failed to create ARRaycastQuery")
        return
      }

      // Kick off the tracked raycast while planes are still on:
      startTrackedRaycast(with: query, color: .green) { [weak self] worldPos in
        guard let self = self else { return }
        // Now that we’ve placed the trunk, disable plane detection
        self.disablePlaneDetection()
        print("  • Plane detection disabled")
        markCount += 1
      }
    }
    
    func placePlaneMarker(color: Color) {
        print("▶ placePlaneMarker() called (markCount = \(markCount))")
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        guard let query = makeRaycastQuery(
            from: center,
            allowing: .existingPlaneInfinite,
            alignment: .vertical
        ) else {
            print("  ✖ Failed to create ARRaycastQuery for infinite plane")
            return
        }

        guard let result = session.raycast(query).first else {
            print("  ✖ Infinite-plane raycast failed")
            return
        }

        let t = result.worldTransform.columns.3
        let worldPos = SIMD3<Float>(t.x, t.y, t.z)
        placeSphere(at: worldPos, color: color)

        if markCount == 1 {
            ARManager.shared.bottomPoint = worldPos
            print("  ✓ Bottom at \(worldPos)")
            markCount += 1
        } else {
            ARManager.shared.topPoint = worldPos
            print("  ✓ Top at \(worldPos)")
            markCount += 1
            
            if let hFloat = ARManager.shared.calculateTreeHeight() {
                let h = Double(hFloat)
                print(String(format: "  ▶ Tree height: %.2f m", h))
                ARManager.shared.actionStream.send(.showHeight(h))
            }
        }
    }
    
    func placeNextTreeMarker() {
        switch markCount {
        case 0:
            placeTrunkMarker()
//            markCount += 1

        case 1, 2:
            // re-enable planes in case you disabled them after the trunk
            enablePlaneDetection()
            placePlaneMarker(color: .red)
//            markCount += 1

        default:
            print("❗ All three tree markers placed already.")
        }
    }

    private func startTrackedRaycast(
        with query: ARRaycastQuery,
        color: Color,
        onFirstHit: @escaping (SIMD3<Float>) -> Void
    ) {
      
        print("▶ placeTrunkMarker() called")
        // 1️⃣ Declare an optional var that both you and your closure can see:
        var trackedRaycast: ARTrackedRaycast?

        // 2️⃣ Kick off the raycast, assigning it to that var:
        trackedRaycast = session.trackedRaycast(query, updateHandler: { [weak self] results in
            guard let self = self, let first = results.first else { return }

            // Compute the world position
            let t = first.worldTransform.columns.3
            let worldPos = SIMD3<Float>(t.x, t.y, t.z)

            // Place your sphere
            self.placeSphere(at: worldPos, color: color)
            print("  • Tracked‐raycast sphere at \(worldPos)")

            // Notify caller
            onFirstHit(worldPos)

            // Now stop *this* tracked raycast
            trackedRaycast?.stopTracking()
      })

        // 3️⃣ Check that it actually started:
        guard let raycast = trackedRaycast else {
            print("  ✖ Failed to start tracked raycast")
            return
        }

        // 4️⃣ Keep it alive somewhere (you already have an array for that):
        trackedRaycasts.append(raycast)
        print("  ✓ Tracked raycast started")
    }




    // MARK: - Sphere Placement
    /// Adds a colored sphere anchor at the given world position
    private func placeSphere(at worldPos: SIMD3<Float>, color: Color) {
        let anchor = AnchorEntity(world: worldPos)
        let sphere = MeshResource.generateSphere(radius: 0.2)
        let material = SimpleMaterial(color: UIColor(color), isMetallic: true)
        let model = ModelEntity(mesh: sphere, materials: [material])
        anchor.addChild(model)
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
    
    /// 1st tap: finds a vertical surface under the crosshair, places a sphere,
    /// then disables plane detection so the anchor will not drift.
    /// Subsequent taps just place spheres (you can customize for base/top logic).
    private func placeSphereViaRaycast(ofColor color: Color, Marker marker: Int) {
        // 1. Raycast from center of screen
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        guard let result = raycast(from: center,
                                   allowing: .estimatedPlane,
                                   alignment: .vertical).first
        else {
            print("Vertical raycast failed — no surface under crosshair")
            return
        }

        // 2. Extract world position
        let worldTransform = result.worldTransform
        let worldPos = SIMD3<Float>(worldTransform.columns.3.x,
                                    worldTransform.columns.3.y,
                                    worldTransform.columns.3.z)

        // 3. Create a fixed‑world anchor (not a plane anchor)
        let anchor = AnchorEntity(plane: .vertical)
        let sphereMesh = MeshResource.generateSphere(radius: 0.2)
        let material   = SimpleMaterial(color: UIColor(color), isMetallic: true)
        let sphereEnt  = ModelEntity(mesh: sphereMesh, materials: [material])
        anchor.addChild(sphereEnt)
        scene.addAnchor(anchor)
        print("Sphere placed at \(worldPos)")

        // 4. On the very first marker (tree trunk), disable plane detection
        markCount += 1
        if markCount == 1 {
          // just placed trunk
          disablePlaneDetection()
        }

    }

    
}
