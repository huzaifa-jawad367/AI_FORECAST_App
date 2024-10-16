//
//  SignInViewModel.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 10/2/24.
//

import Foundation

@MainActor
class SignInViewModel: ObservableObject {
    
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

    
    func RegisterWithEmail(email: String, password: String, username: String) async throws {
        
    }
    
    func SignInWithEmail(email: String, password: String) async throws {
        
    }

}



extension String {
    func isEmailValid() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: self)
    }
}
