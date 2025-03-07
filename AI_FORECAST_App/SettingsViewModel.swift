//
//  SettingsViewModel.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 26/02/2025.
//

import SwiftUI
import Supabase

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var currentUser: UserRecord? = nil
    @Published var isSignedIn: Bool = false
    
    // We'll rely on the session manager's supabaseClient or create our own
    private let supabaseClient = client
    
    // Fetch user profile from "users" table using the user's ID
    func fetchUserProfile(userID: String) async throws -> UserRecord {

        // Query the "users" table for a single matching ID
        let response = try await client.database
                    .from("users")
                    .select("id, full_name, profile_picture_url")
                    .eq("id", value: userID) // ✅ Corrected .eq() syntax
                    .single()
                    .execute()
        
        // Decode JSON into our UserProfile struct
        let profile = try JSONDecoder().decode(UserRecord.self, from: response.data)
        currentUser = profile
        isSignedIn = true
        print("Fetched user profile: \(profile)")
        return profile
        
    }
    
    func logOut() {
        Task {
            do {
                try await supabaseClient.auth.signOut()
                currentUser = nil
                isSignedIn = false
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteAccount() {
        // You might call a Supabase RPC or API to delete the user record.
        // Or rely on the auth admin API if you have it set up.
    }
}
