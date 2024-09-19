//
//  ContentView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 9/16/24.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSignedIn: Bool = false
    
    var body: some View {
        ZStack {
            ARViewContainer().edgesIgnoringSafeArea(.all)
            
//            if !isSignedIn {
//                VStack {
//                    Spacer()
//                    
//                    // Sign-in form
//                    VStack(spacing: 16) {
//                        Text("Sign In")
//                    }
//                }
//            }
            if !isSignedIn {
                VStack {
                    Spacer()
                    // Sign-in form
                    VStack(spacing: 16) {
                        Text("Sign In").font(.largeTitle).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).multilineTextAlignment(.leading).padding(.bottom, 20)
                        
                        TextField("Email", text:$email).padding().background(Color(.secondarySystemBackground)).cornerRadius(10)
                        
                        // Password SecureField
                        SecureField("Password", text: $password).padding().background(Color(.secondarySystemBackground)).cornerRadius(10)
                        
                        // Signin Button
                        Button(action: {
                            //Logic to handle sign-in
                            signIn()
                        }) {
                            Text("Sign In").font(.headline).foregroundColor(.white).frame(width: 200, height: 50).background(Color.blue).cornerRadius(10)
                        }
                        
                    }
                    .padding().background(Color.white.opacity(0.9)).cornerRadius(20).padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding()
            }
            
        }
    }
    
    func signIn() {
            // Example sign-in logic
            if !email.isEmpty && !password.isEmpty {
                isSignedIn = true // Successful sign-in example
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
