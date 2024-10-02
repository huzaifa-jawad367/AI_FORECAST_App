//
//  SignUpView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 10/2/24.
//

import SwiftUI

struct SignUpView: View {
    
    @Binding var authState: AuthState
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirm_password = ""
    @State private var username: String = ""
    @State private var isSignedUp: Bool = false
    
    var body: some View {
        
        ZStack {
            Image("forest_wallpaper")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            
            VStack {
                Spacer()
                
                VStack (spacing: 16) {
                    Text("Sign Up")
                        .font(.largeTitle).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).multilineTextAlignment(.leading).padding(.bottom, 20)
                    
                    
                    TextField("Email", text:$email).padding().background(Color(.secondarySystemBackground)).cornerRadius(10).autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/).keyboardType(.emailAddress)
                    
                    TextField("Username", text:$username).padding().background(Color(.secondarySystemBackground)).cornerRadius(10).autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    
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
                    
                    Button(action: {
                        authState = .signIn
                    }) {
                        Text("Already have an account? Sign In")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 10)
                    
                }
                .padding().background(Color.white.opacity(0.5)).cornerRadius(20).padding(.horizontal, 20)
                
                Spacer()
            }
            .padding()
        }
        
        
    }
    
    func signUp() {
        if !email.isEmpty && !username.isEmpty && !password.isEmpty && !confirm_password.isEmpty {
            isSignedUp = true
        }
    }
}


#Preview {
    SignUpView(authState: .constant(.signUp))
}
