//
//  SignUpView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 10/2/24.
//

import AuthenticationServices
import SwiftUI

struct SignUpView: View {
    
    @Binding var authState: AuthState
//    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirm_password = ""
    @State private var username: String = ""
    @State private var isSignedUp: Bool = false
    
    @StateObject private var signInViewModel = SignInViewModel()
    
    @AppStorage("email") var email: String = ""
    
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var showingSuccessAlert = false
    
    var body: some View {
        
        ZStack {
            Image("forest_wallpaper")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .overlay(Color.black.opacity(0.15))
                .accessibilityHidden(true)
            
            
            VStack {
                Spacer()
                
                VStack (spacing: 16) {
                    Text("Sign Up")
                        .font(.largeTitle)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 20)
                        .accessibilityAddTraits(.isHeader)
                    
                    
                    TextField("Email", text:$email).padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .accessibilityLabel("Email")
                        .accessibilityHint("Enter your email address")
                    
                    TextField("Username", text:$username).padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                        .accessibilityLabel("Username")
                        .accessibilityHint("Enter your username")
                    
                    // Password SecureField
                    SecureField("Password", text: $password).padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .accessibilityLabel("Password")
                        .accessibilityHint("Enter your Password")
                    
                    // Confirm Password SecureField
                    SecureField("Confirm Password", text: $confirm_password).padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .accessibilityLabel("Confirm Password")
                        .accessibilityHint("Enter your password again to confirm")
                    
                    // Signin Button
                    Button(action: {
                        //Logic to handle sign-in
                        signUp()
                    }) {
                        Text("Sign Up").font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .accessibilityLabel("Sign Up")
                    .accessibilityHint("Tap to create your account")
                    
                    Button(action: {
                        authState = .signIn
                    }) {
                        Text("Already have an account? Sign In")
                            .font(.footnote)
                            .foregroundColor(.blue)
                            .bold()
                    }
                    .padding(.top, 10)
                    .accessibilityLabel("Sign In")
                    .accessibilityHint("Tap to navigate to the sign in screen")
                    
                    // -- OR Sign Up with Apple --
//                    Button(action: {
//                        
//                    }) {
//                        HStack {
//                            Image(systemName: "applelogo")
//                            
//                            Text("Sign Up with Apple")
//                        }
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .frame(width: 300, height: 50)
//                        .background(Color.black)
//                        .cornerRadius(30)
//                    }
                    
//                    SignInWithAppleButton(.continue) { request in
//                        
//                        request.requestedScopes = [.email, .fullName]
//                        
//                    } onCompletion: { result in
//                        
//                        switch result {
//                        case .success(let auth):
//                            
//                            switch auth.credential {
//                            case let credential as ASAuthorizationAppleIDCredential:
//                                
//                                // User id
//                                let userId = credential.user
//                                
//                                // User Info
//                                let email = credential.email
//                                let firstName = credential.fullName?.givenName
//                                let lastName = credential.fullName?.familyName
//                                
//                            default:
//                                break
//                            }
//                            
//                        case .failure(let error):
//                            print(error)
//                        }
//                    }
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .frame(width: 300, height: 50)
//                    .background(Color.black)
//                    .cornerRadius(30)
//                    .accessibilityLabel("Sign Up with Apple")
//                    .accessibilityHint("Tap to sign up using your Apple account")
                    
                    // // -- OR Sign Up with Google --
                    // Button(action: {
                            
                    // }) {
                    //     HStack {
                    //         Image("google-icon") // your custom google icon
                    //             .resizable()
                    //             .frame(width: 20, height: 20)
                    //         Text("Sign Up with Google")
                    //     }
                    //     .font(.headline)
                    //     .foregroundColor(.white)
                    //     .frame(width: 300, height: 50)
                    //     .background(Color.red)
                    //     .cornerRadius(30)
                    // }
                    // .accessibilityLabel("Sign Up with Google")
                    // .accessibilityHint("Tap to sign up using your Google account")
                    
                    // // -- OR Sign Up with Facebook --
                    // Button(action: {
                        
                    // }) {
                    //     HStack {
                    //         Image("facebook-icon") // your custom facebook icon
                    //             .resizable()
                    //             .frame(width: 30, height: 20)
                    //         Text("Sign Up with Facebook")
                    //     }
                    //     .font(.headline)
                    //     .foregroundColor(.white)
                    //     .frame(width: 300, height: 50)
                    //     .background(Color.blue)
                    //     .cornerRadius(30)
                    // }
                    // .accessibilityLabel("Sign Up with Facebook")
                    // .accessibilityHint("Tap to sign up using your Facebook account")
                    
                }
                .padding()
                .background(Color.white.opacity(0.5))
                .cornerRadius(20)
                .padding(.horizontal, 20)
                .alert(isPresented: $showingErrorAlert) {
                    Alert(
                        title: Text("Sign Up Failed"),
                        message: Text(errorMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .alert(isPresented: $showingSuccessAlert) {
                    Alert(
                        title: Text("Account Created"),
                        message: Text("Your account has been successfully created."),
                        dismissButton: .default(Text("OK"), action: {
                            authState = .signIn // optional: move to login after success
                        })
                    )
                }
                
                Spacer()
            }
            .padding()
        }
        
        
    }
    
    func signUp() {
        // 1. Basic checks (e.g., ensure passwords match)
        // Check if form fields are filled
        guard !email.isEmpty, !username.isEmpty, !password.isEmpty, !confirm_password.isEmpty else {
            errorMessage = "Please fill in all fields."
            showingErrorAlert = true
            print("Please fill in all fields.")
            return
        }
        
        // Confirm passwords match
        guard password == confirm_password else {
            errorMessage = "Passwords do not match."
            showingErrorAlert = true
            print("Passwords do not match.")
            return
        }
        
        // Optionally, do extra validation using the isSignUpFormValid
        guard signInViewModel.isSignUpFormValid(email: email, password: password, username: username) else {
            errorMessage = "Invalid email or password format."
            showingErrorAlert = true
            print("Sign up form is invalid. Check logs.")
            return
        }
        
    // 3. Perform the sign up using a Task to allow async/await calls
        Task {
            do {
                try await signInViewModel.RegisterWithEmail(
                    email: email,
                    password: password,
                    username: username
                )
                showingSuccessAlert = true
                // If successful, set `isSignedUp = true` or navigate to another screen, etc.
                isSignedUp = true
            } catch {
                errorMessage = "Sign up failed: \(error.localizedDescription)"
                showingErrorAlert = true
                // Handle error (show alert, etc.)
                print("Sign up failed: \(error.localizedDescription)")
            }
        }
    }

}


#Preview {
    SignUpView(authState: .constant(.signUp))
}
