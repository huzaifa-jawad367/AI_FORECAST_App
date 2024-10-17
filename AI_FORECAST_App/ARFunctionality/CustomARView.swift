//
//  CustomARView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 09/10/2024.
//

import ARKit
import RealityKit
import SwiftUI

struct ContentARView: View {
    var body: some View {
        CustomARViewRepresentable()
            .ignoresSafeArea()
    }
}

class CustomARView: ARView {
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
    }
    
    dynamic required init? (coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemted ")
    }
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds )
        
        placeBlueBlock() 
    }
    
    func configurationExamples() {
        let configuration = ARWorldTrackingConfiguration()
        session.run(configuration)
        
        // Not available in all region and only available in some major cities of the US and Europe
        let _ = ARGeoTrackingConfiguration()
        
        // Tracks faces in a scene
        let _ = ARFaceTrackingConfiguration()
        
        // Tracks bodies in a scene
        let _ = ARBodyTrackingConfiguration()
    }
    
    func anchorExample() {
        // attach anchors at specific coordinates in the iPhone-centered coordinate system
        let coordinateAnchor = AnchorEntity(world: .zero)
        
        // attach anchors to detect planes (this works best on devices with a LiDAR sensor
        let horizontalAnchor = AnchorEntity(.plane(.horizontal,
                                    classification: .any,
                                    minimumBounds: SIMD2<Float>(0.2, 0.2)
                ))
        let _ = AnchorEntity(.plane(.vertical,
                                    classification: .any,
                                    minimumBounds: SIMD2<Float>(0.2, 0.2)
                ))
        
        let _ = AnchorEntity(.face)
        
        let _ = AnchorEntity(.image(group: "group", name: "name"))
        
        scene.addAnchor(coordinateAnchor)
        scene.addAnchor(horizontalAnchor)
    }
    
    func entityExamples() {
        // Load an entity from a usdz file
        let _ = try? Entity.load(named: "usdzFileName")
        
        // Load an entity from a reality file
        let _ = try? Entity.load(named: "realityFileName")
        
        // Generate an entiity with code
        let box = MeshResource.generateBox(size: 1)
        let entity = ModelEntity(mesh: box)
        
        // Add entity to an anchor, so it's placed in the scene
        let horizontalAnchor = AnchorEntity(.plane(.horizontal,
                                    classification: .any,
                                    minimumBounds: SIMD2<Float>(0.2, 0.2)
                ))
        horizontalAnchor.addChild(entity)
    }
    
    func placeBlueBlock() {
        let block = MeshResource.generateBox(size: 1)
        let material = SimpleMaterial(color: .blue, isMetallic: false)
        let entity = ModelEntity(mesh: block, materials: [material])
        
        let anchor = AnchorEntity(plane: .horizontal)
        anchor.addChild(entity)
        
        scene.addAnchor(anchor)
    }
    
}

#Preview {
    CustomARView()
}
