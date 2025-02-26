//
//  SettingsViewModel.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 26/02/2025.
//

import Combine
import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var currentUser: UserProfile?

    // Example user model to mirror the Supabase data you have:
    struct UserProfile {
        let id: String
        let fullName: String
        let email: String
        let profilePictureUrl: String?
    }
    
    init() {
        // For demo purposes, simulate fetching user session
        // In production, you'd fetch from Supabase Auth + your "users" table.
        fetchUserSession()
    }
    
    func fetchUserSession() {
        // Example: if user is signed in, create a UserProfile object.
        // Replace with your own Supabase user fetch logic.
        
        // If user is signed in:
        isSignedIn = true
        currentUser = UserProfile(
            id: "a8401b31-9c23-4b31-b969-92dfcdb86608",
            fullName: "Alice Johnson",
            email: "[email protected]",
            profilePictureUrl: "https://example.com/profiles/alice.jpg"
        )
        
        // If user is not signed in:
        // isSignedIn = false
        // currentUser = nil
    }
    
    func logOut() {
        // Clear session, log out from Supabase or your custom auth
        isSignedIn = false
        currentUser = nil
    }
    
    func deleteAccount() {
        // Call your Supabase "delete user" endpoint
        // Then log out or handle UI feedback
        logOut()
    }
}
