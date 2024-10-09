//
//  ContentView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 9/16/24.
//

import SwiftUI
import RealityKit
import ARKit
import UIKit


struct ScanPageView: View {
    
    @Binding var authState: AuthState
    
    var body: some View {
        Text("Hello").font(.largeTitle)
    }
}


struct ContentView : View {
    
    @State private var authState: AuthState = .signIn
    
    var body: some View {
        ZStack {
            ARViewContainer().edgesIgnoringSafeArea(.all)

            switch authState {
            case .signIn:
                SignInView(authState: $authState)
            case .signUp:
                SignUpView(authState: $authState)
            case .scanPage:
                DashBoardView(authState: $authState)
            }
            
        }
        
    }
}


struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)

        // Create a cube model
        let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
        let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
        let model = ModelEntity(mesh: mesh, materials: [material])
        model.transform.translation.y = 0.05

        // Create horizontal plane anchor for the content
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
        anchor.children.append(model)

        // Add the horizontal plane anchor to the scene
        arView.scene.anchors.append(anchor)

        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

#Preview {
    ContentView()
}


