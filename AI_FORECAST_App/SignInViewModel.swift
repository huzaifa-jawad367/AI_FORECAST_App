//
//  SignInViewModel.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 10/2/24.
//

import Foundation
import Supabase

@MainActor
class SignInViewModel: ObservableObject {
    private let supabaseClient = client
    
    func isSignInFormValid(email: String, password: String) -> Bool {
        guard !email.isEmpty else {
            print("Email field is empty")
            return false
        }
        
        guard email.isEmailValid() else {
            print("Invalid email format")
            return false
        }
        
        guard !password.isEmpty else {
            print("Password field is empty")
            return false
        }
        
        guard password.count >= 8 else {
            print("Password must be at least 8 characters long")
            return false
        }
        
        return true
    }
    
    func isSignUpFormValid(email: String, password: String, username: String) -> Bool {
        // Validate email format and check if email is empty
        guard !email.isEmpty else {
            print("Email field is empty")
            return false
        }
        
        guard email.isEmailValid() else {
            print("Invalid email format")
            return false
        }
        
        // Validate password length and check if password is empty
        guard !password.isEmpty else {
            print("Password field is empty")
            return false
        }
        
        guard password.count >= 8 else {
            print("Password must be at least 8 characters long")
            return false
        }
        
        // Validate username is not empty
        guard !username.isEmpty else {
            print("Username field is empty")
            return false
        }
        
        // If all validations pass
        return true
    }

    /// Registers a new user using the Supabase `signUp` method.
    ///
    /// - Parameters:
    ///   - email: User's email
    ///   - password: User's password
    ///   - username: Additional user metadata field
    func RegisterWithEmail(email: String, password: String, username: String) async throws {
        
        do {
            // Sign up user.
            // Depending on your supabase-swift version, you can pass
            // user metadata as shown below. For example:
            let result = try await client.auth.signUp(
                email: email,
                password: password,
                data: ["Display name": .string(username)]
              )
            
            let user = result.user
            print("Sign up successful. User ID: \(user.id)")
            
        } catch {
            // Bubble up the error so callers can handle it
            print("Sign up error:", error.localizedDescription)
            throw error
        }
    }
    
    func SignInWithEmail(email: String, password: String) async throws {
        do {
            // If you are on a recent version of supabase-swift, you can do:
            // `signInWithPassword(email:password:)`
            let result = try await client.auth.signIn(
                email: email,
                password: password
            )
            
            // `result.user` is a non-optional User object
            let user = result.user
            print("Sign in successful. User ID: \(user.id)")
            
            // If needed, you can also look at `result.session` for tokens, etc.
            // let session = result.session
            // print("Access Token: \(session?.accessToken ?? "")")
            
        } catch {
            print("Sign in error:", error.localizedDescription)
            throw error
        }
    }


}



extension String {
    func isEmailValid() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: self)
    }
}
