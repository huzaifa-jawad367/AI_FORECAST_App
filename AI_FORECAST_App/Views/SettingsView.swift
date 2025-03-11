//
//  SettingsView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 26/02/2025.
//

import SwiftUI

struct SettingsView: View {
    @Binding var authState: AuthState
    @StateObject private var viewModel = SettingsViewModel()
    
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        
        
        VStack {
            HStack {
                Button(action: {
                    authState = .Dashboard
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                        Text("Dashboard")
                            .font(.body)
                    }
                    .foregroundColor(.blue)
                }
                // Accessibility for Back Button
                .accessibilityLabel("Back to Dashboard")
                .accessibilityHint("Tap to return to the dashboard screen")
                
                Spacer()
            }
            .padding(.top)
            
            
            NavigationView {
                VStack {
                    
                    if viewModel.isSignedIn, let user = viewModel.currentUser {
                        List {
                            // --- User Info Section ---
                            Section {
                                HStack(spacing: 16) {
                                    AsyncImage(url: URL(string: user.profile_picture_url ?? "")) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        // Placeholder if no profile pic is available
                                        Circle()
                                            .fill(Color.gray.opacity(0.3))
                                            .overlay(Text("No Image"))
                                    }
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(user.username)
                                            .font(.headline)
                                        Text(sessionManager.user?.email ?? "No email provided")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.vertical, 4)
                                // Group the user info for accessibility
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("User Information")
                                .accessibilityValue("\(user.username), email: \(sessionManager.user?.email ?? "No email provided")")
                            }
                            
                            // --- Edit Profile Section ---
                            Section {
                                NavigationLink("Edit Profile", destination: EditProfileView())
                                    .accessibilityLabel("Edit Profile")
                                    .accessibilityHint("Tap to edit your profile information")
                            }
                            
                            // --- Account Actions Section ---
                            Section {
                                Button("Log Out") {
                                    viewModel.logOut()
                                }
                                .accessibilityLabel("Log Out")
                                .accessibilityHint("Tap to log out from your account")
                                
                                Button("Delete Account", role: .destructive) {
                                    
                                    Task {
                                        await viewModel.deleteAccount()
                                    }
                                    
                                    authState = .signIn
                                    
                                }
                                .accessibilityLabel("Delete Account")
                                .accessibilityHint("Tap to permanently delete your account")
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                    } else {
                        // If not signed in, show a fallback view
                        VStack(spacing: 20) {
                            Text("You are not signed in.")
                                .font(.title3)
                                .foregroundColor(.gray)
                                // Accessibility
                                .accessibilityLabel("Not signed in")
                                .accessibilityHint("Please sign in to access your settings")
                            
                            Button("Sign In") {
                                // Trigger your sign-in flow
                                authState = .signIn
                                print("Sign in tapped")
                            }
                            .buttonStyle(.borderedProminent)
                            .accessibilityLabel("Sign In")
                            .accessibilityHint("Tap to sign in to your account")
                        }
                        .padding()
                    }
                }
                .navigationTitle("Settings")
            }
            .task {
                await loadUserProfileIfSignedIn()
            }

        }
        
    }
    
    /// Loads the user profile from the supabase Database if sessionManager.user exists
    func loadUserProfileIfSignedIn() async {
        guard let supabaseUser = sessionManager.user else {
            viewModel.isSignedIn = false
            return
        }
        
        do {
            // fetch the user instance
            let profile = try await viewModel.fetchUserProfile(userID: supabaseUser.id.uuidString)
            viewModel.currentUser = profile
            viewModel.isSignedIn = true
        } catch {
            print("Error fetch profile: \(error.localizedDescription)")
            viewModel.isSignedIn = false
        }
    }
}

// --- Example Placeholder for Edit Profile ---
struct EditProfileView: View {
    var body: some View {
        Text("Edit Profile Screen")
            .navigationTitle("Edit Profile")
    }
}



struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(authState: .constant(.Settings))
            .environmentObject(SessionManager()) // ✅ Provide the session manager
    }
}
