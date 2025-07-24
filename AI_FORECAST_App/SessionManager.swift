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

    // Cached profile image
    @Published var cachedProfileImage: UIImage?
    
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

    func fetchProfilePicture() async {
        guard let user = self.user else { return }
        let userId = user.id.uuidString.lowercased()
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("profile-\(userId).jpg")
        do {
            // Check if cached file exists
            if FileManager.default.fileExists(atPath: cacheURL.path) {
                if let image = UIImage(contentsOfFile: cacheURL.path) {
                    await MainActor.run {
                        self.cachedProfileImage = image
                    }
                    return
                }
            }
            // Fetch remote URL from Supabase
            let response = try await client.database
                .from("users")
                .select("profile_picture_url")
                .eq("id", value: userId)
                .single()
                .execute()
            struct ProfilePicResponse: Decodable {
                let profile_picture_url: String?
            }
            let profile = try JSONDecoder().decode(ProfilePicResponse.self, from: response.data)
            guard let urlString = profile.profile_picture_url, let url = URL(string: urlString) else {
                print("No profile_picture_url found for user.")
                return
            }
            let (data, _) = try await URLSession.shared.data(from: url)
            // Write to cache atomically
            try data.write(to: cacheURL, options: .atomic)
            if let image = UIImage(data: data) {
                await MainActor.run {
                    self.cachedProfileImage = image
                }
            }
        } catch {
            print("Failed to fetch or cache profile picture: \(error.localizedDescription)")
        }
    }
}
