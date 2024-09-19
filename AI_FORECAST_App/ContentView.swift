//
//  ContentView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 9/16/24.
//

import SwiftUI
import RealityKit

struct SignInView: View {

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSignedIn: Bool = false

    var body: some View {
        VStack {
            Spacer()
            // Sign-in form
            VStack(spacing: 16) {
                Text("Sign In")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 20)

                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                // Signin Button
                Button(action: {
                    signIn()
                }) {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: SignUpView()) {
                    Text("Don't have an account? Sign Up")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                .padding(.top, 10)
            }
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(20)
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding()
    }

    func signIn() {
        if !email.isEmpty && !password.isEmpty {
            isSignedIn = true
        }
    }
}

struct SignUpView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirm_password = ""
    @State private var username: String = ""
    @State private var isSignedUp: Bool = false
    
    var body: some View {
        
        VStack {
            Spacer()
            
            VStack (spacing: 16) {
                Text("Sign Up")
                    .font(.largeTitle).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).multilineTextAlignment(.leading).padding(.bottom, 20)
                
                
                TextField("Email", text:$email).padding().background(Color(.secondarySystemBackground)).cornerRadius(10)
                
                TextField("Username", text:$username).padding().background(Color(.secondarySystemBackground)).cornerRadius(10)
                
                // Password SecureField
                SecureField("Password", text: $password).padding().background(Color(.secondarySystemBackground)).cornerRadius(10)
                
                // Confirm Password SecureField
                SecureField("Confirm Password", text: $confirm_password).padding().background(Color(.secondarySystemBackground)).cornerRadius(10)
                
                // Signin Button
                Button(action: {
                    //Logic to handle sign-in
                    signUp()
                }) {
                    Text("Sign Up").font(.headline).foregroundColor(.white).frame(width: 200, height: 50).background(Color.blue).cornerRadius(10)
                }
                
                NavigationLink (destination: ContentView()) {
                    Text("Already have an account? Sign in")
                        .font(.footnote)
                        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                }
                .padding(.top, 10)
            }
            .padding().background(Color.white.opacity(0.9)).cornerRadius(20).padding(.horizontal, 20)
            
            Spacer()
        }
        .padding()
        
        
    }
    
    func signUp() {
        if !email.isEmpty && !username.isEmpty && !password.isEmpty && !confirm_password.isEmpty {
            isSignedUp = true
        }
    }
}



struct ContentView : View {
    
    var body: some View {
        NavigationView {
            ZStack {
                ARViewContainer().edgesIgnoringSafeArea(.all)

                // Use SignInView for the sign-in form
                SignInView()
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
