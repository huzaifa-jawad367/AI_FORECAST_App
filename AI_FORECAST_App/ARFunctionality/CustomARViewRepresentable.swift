//
//  CustomARViewRepresentable.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 09/10/2024.
//

import SwiftUI
import RealityKit

//struct ARViewContainer: UIViewRepresentable {
//    
//    func makeUIView(context: Context) -> ARView {
//        
//        let arView = ARView(frame: .zero)
//
//        // Create a cube model
//        let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
//        let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
//        let model = ModelEntity(mesh: mesh, materials: [material])
//        model.transform.translation.y = 0.05
//
//        // Create horizontal plane anchor for the content
//        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
//        anchor.children.append(model)
//
//        // Add the horizontal plane anchor to the scene
//        arView.scene.anchors.append(anchor)
//
//        return arView
//        
//    }
//    func makeUIView(context: Context) -> CustomARView {
//        return CustomARView()
//    }
//    
//    func updateUIView(_ uiView: CustomARView, context: Context) {}
//    
//}

struct CustomARViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> CustomARView {
        return CustomARView(frame: UIScreen.main.bounds)
    }

    func updateUIView(_ uiView: CustomARView, context: Context) {}
}


