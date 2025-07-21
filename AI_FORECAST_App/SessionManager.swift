//
//  SessionManager.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 28/02/2025.
//

import SwiftUI
import Supabase

class SessionManager: ObservableObject {
    // The currently signed-in user (nil if logged out)
    @Published var user: User? = nil
    
    // Possibly store the session itself if you need tokens
    // @Published var session: Session? = nil
    
    @Published var authState: AuthState = .signIn
    
    // A quick helper to check if user is signed in
    var isSignedIn: Bool {
        user != nil
    }
    
    // Provide a reference to your Supabase client if you’d like
    // or you can keep it private.
    let supabaseClient: SupabaseClient = client
    
    // Sign out:
//    func signOut() async throws {
//        do {
//            try await supabaseClient.auth.signOut()
//            user = nil
//            // session = nil
//        } catch {
//            print("Sign out error: \(error.localizedDescription)")
//            throw error
//        }
//    }
    // Sign out
    func signOut() async throws {
        try await supabaseClient.auth.signOut()
        user = nil
        authState = .signIn
    }
}
