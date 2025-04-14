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
    
    @EnvironmentObject var sessionManager: SessionManager 
    @StateObject private var signInViewModel = SignInViewModel()
    
    var body: some View {
        
        ZStack {
            Image("forest_wallpaper") 
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .accessibilityHidden(true)
            
            VStack {
                Spacer()
                // Sign-in form
                VStack(spacing: 16) {
                    Text("Sign In")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 20)
                        .accessibilityAddTraits(.isHeader)
                        .foregroundColor(.black)
                    
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .accessibilityLabel("Email")
                        .accessibilityHint("Enter your email address")
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .accessibilityLabel("Password")
                        .accessibilityHint("Enter your password")
                    
                    // Signin Button
                    Button(action: {
                        signIn()
//                        authState = .Dashboard
                    }) {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .accessibilityLabel("Sign In")
                    .accessibilityHint("Tap to sign in using your email and password")
                    
                    Button(action: {
                        authState = .signUp
                    }) {
                        Text("Don't have an account? Sign Up")
                            .font(.footnote)
                            .foregroundColor(.blue)
                            .bold()
                    }
                    .padding(.top, 10)
                    .accessibilityLabel("Sign Up")
                    .accessibilityHint("Tap to navigate to the sign up screen")
                    
                    // -- OR Sign In with Google --
                    Button(action: {
                        
                    }) {
                        HStack {
                            Image(systemName: "applelogo")
                            
                            Text("Sign In with Apple")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 300, height: 50)
                        .background(Color.black)
                        .cornerRadius(30)
                    }
                    .accessibilityLabel("Sign In with Apple")
                    .accessibilityHint("Tap to sign in using your Apple account")
                    
                    // -- OR Sign In with Google --
                    Button(action: {
                            
                    }) {
                        HStack {
                            Image("google-icon") // your custom google icon
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("Sign In with Google")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 300, height: 50)
                        .background(Color.red)
                        .cornerRadius(30)
                    }
                    .accessibilityLabel("Sign In with Google")
                    .accessibilityHint("Tap to sign in using your Google account")
                    
                    // -- OR Sign In with Facebook --
                    Button(action: {
                        
                    }) {
                        HStack {
                            Image("facebook-icon") // your custom facebook icon
                                .resizable()
                                .frame(width: 30, height: 20)
                            Text("Sign In with Facebook")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 300, height: 50)
                        .background(Color.blue)
                        .cornerRadius(30)
                    }
                    .accessibilityLabel("Sign In with Facebook")
                    .accessibilityHint("Tap to sign in using your Facebook account")

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
        
        guard !email.isEmpty, !password.isEmpty else {
            print("Please fill in all fields.")
            return
        }
        
        // validation using the isSignUpFormValid
        guard signInViewModel.isSignInFormValid(email: email, password: password) else {
            print("Sign up form is invalid. Check logs.")
            return
        }
        
    //  Perform the sign up using a Task to allow async/await calls
        Task {
            do {
                try await signInViewModel.signInWithEmail(
                    email: email,
                    password: password,
                    sessionManager: sessionManager
                )
                // If successful, set `isSignedUp = true` or navigate to another screen, etc.
                isSignedIn = true
                authState = .Dashboard
            } catch {
                // Handle error (show alert, etc.)
                print("Sign in failed: \(error.localizedDescription)")
            }
        }
    }
}


#Preview {
    SignInView(authState: .constant(.signIn))
}
