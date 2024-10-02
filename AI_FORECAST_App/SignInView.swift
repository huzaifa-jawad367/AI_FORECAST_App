//
//  SignInView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 10/2/24.
//

import SwiftUI

struct SignInView: View {

    @Binding var authState: AuthState
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSignedIn: Bool = false

    var body: some View {
        
        ZStack {
            Image("forest_wallpaper")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
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
                        .cornerRadius(10).autocapitalization(.none).keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    
                    // Signin Button
                    Button(action: {
                        signIn()
                        authState = .scanPage
                    }) {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        authState = .signUp
                    }) {
                        Text("Don't have an account? Sign Up")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 10)
                }
                .padding()
                .background(Color.white.opacity(0.6))
                .cornerRadius(20)
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .padding()
            
        }
        
    }

    func signIn() {
        if !email.isEmpty && !password.isEmpty {
            isSignedIn = true
        }
    }
}


#Preview {
    SignInView(authState: .constant(.signIn))
}
