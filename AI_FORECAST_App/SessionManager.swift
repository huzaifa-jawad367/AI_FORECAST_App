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
    
    // Store the session itself for token management
    @Published var session: Session? = nil
    
    @Published var authState: AuthState = .signIn
    
    // Offline mode tracking
    @Published var isOffline: Bool = false
    
    // A quick helper to check if user is signed in
    var isSignedIn: Bool {
        user != nil
    }
    
    // Provide a reference to your Supabase client if you'd like
    // or you can keep it private.
    let supabaseClient: SupabaseClient = client
    
    // Keychain manager for persistent storage
    private let keychainManager = KeychainManager.shared
    
    // Timer for automatic token refresh
    private var tokenRefreshTimer: Timer?
    
    init() {
        // setupAuthListener() // Temporarily disabled due to syntax issues
    }
    
    // MARK: - Session Management
    
    /// Store session in Keychain after successful authentication
    func storeSession(_ session: Session) {
        do {
            try keychainManager.storeSession(session)
            try keychainManager.storeUserData(session.user)
            self.session = session
            self.user = session.user
            print("✅ Session stored successfully in Keychain")
        } catch {
            print("❌ Failed to store session: \(error.localizedDescription)")
        }
    }
    
    /// Restore session from Keychain or Supabase with proper offline handling
    func restoreSession() async {
        // First, try to restore from Keychain (offline support)
        if let storedUser = try? keychainManager.retrieveUserData(),
           let storedTokens = try? keychainManager.retrieveSession() {
            
            // Check if stored tokens are still valid
            if !storedTokens.isExpired {
                await MainActor.run {
                    self.user = storedUser
                    self.authState = .Dashboard
                    self.isOffline = false
                    print("✅ Session restored from Keychain (valid tokens)")
                }
                
                // Try to refresh tokens in background if they're getting close to expiry
                if storedTokens.willExpireSoon {
                    Task {
                        await refreshTokensIfNeeded()
                    }
                }
            } else {
                // Tokens are expired, but we can still work offline
                await MainActor.run {
                    self.user = storedUser
                    self.authState = .Dashboard
                    self.isOffline = true
                    print("⚠️ Session restored from Keychain (expired tokens - offline mode)")
                }
            }
        }
        
        // Then try to restore from Supabase (online mode)
        do {
            let session = try await supabaseClient.auth.session
            
            // Store the fresh session in Keychain
            storeSession(session)
            
            await MainActor.run {
                self.user = session.user
                self.session = session
                self.authState = .Dashboard
                self.isOffline = false
                print("✅ Session restored from Supabase (online mode)")
            }
            
            // Set up automatic token refresh
            setupAutomaticTokenRefresh()
            
        } catch {
            await MainActor.run {
                // If Supabase fails but we have Keychain data, stay in offline mode
                if self.user == nil {
                    self.user = nil
                    self.session = nil
                    self.authState = .signIn
                    print("❌ No valid session found")
                } else {
                    self.isOffline = true
                    print("⚠️ Using offline session - network unavailable")
                }
            }
        }
    }
    
    /// Sign out and clear all stored data
    func signOut() async throws {
        // Stop automatic token refresh
        stopAutomaticTokenRefresh()
        
        do {
            // Try to sign out from Supabase if online
            try await supabaseClient.auth.signOut()
            print("✅ Signed out from Supabase")
        } catch {
            print("⚠️ Failed to sign out from Supabase (offline mode): \(error.localizedDescription)")
        }
        
        // Always clear local data
        do {
            try keychainManager.clearAllData()
            print("✅ Cleared all local session data")
        } catch {
            print("❌ Failed to clear local data: \(error.localizedDescription)")
        }
        
        await MainActor.run {
            self.user = nil
            self.session = nil
            self.authState = .signIn
            self.isOffline = false
        }
    }
    
    /// Check if we have a valid stored session
    func hasValidStoredSession() -> Bool {
        return keychainManager.hasValidStoredSession()
    }
    
    /// Enhanced token refresh with better error handling
    func refreshTokensIfNeeded() async {
        // Try to get session from Keychain if not in memory
        var currentSession = session
        if currentSession == nil {
            if let storedTokens = try? keychainManager.retrieveSession() {
                // We have stored tokens, let's try to refresh them
                do {
                    let newSession = try await supabaseClient.auth.refreshSession(refreshToken: storedTokens.refreshToken)
                    storeSession(newSession)
                    currentSession = newSession
                    print("✅ Tokens refreshed successfully from stored refresh token")
                    
                    await MainActor.run {
                        self.isOffline = false
                    }
                    return
                } catch {
                    print("❌ Failed to refresh tokens from stored refresh token: \(error.localizedDescription)")
                    await MainActor.run {
                        self.isOffline = true
                    }
                    return
                }
            } else {
                print("⚠️ No session or stored tokens available for refresh")
                return
            }
        }
        
        guard let session = currentSession else { return }
        
        // Check if tokens need refresh
        let tokens = SessionTokens(from: session)
        if tokens.willExpireSoon {
            do {
                let newSession = try await supabaseClient.auth.refreshSession(refreshToken: tokens.refreshToken)
                storeSession(newSession)
                print("✅ Tokens refreshed successfully")
                
                await MainActor.run {
                    self.isOffline = false
                }
            } catch {
                print("❌ Failed to refresh tokens: \(error.localizedDescription)")
                
                // If refresh fails and tokens are expired, go offline
                if tokens.isExpired {
                    await MainActor.run {
                        self.isOffline = true
                    }
                    print("⚠️ Tokens expired and refresh failed - switching to offline mode")
                }
            }
        }
    }
    
    /// Set up automatic token refresh
    private func setupAutomaticTokenRefresh() {
        // Cancel any existing timer
        tokenRefreshTimer?.invalidate()
        
        // Set up a timer to check tokens every 5 minutes
        tokenRefreshTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            Task {
                await self?.refreshTokensIfNeeded()
            }
        }
        
        print("✅ Automatic token refresh set up (every 5 minutes)")
    }
    
    /// Stop automatic token refresh
    private func stopAutomaticTokenRefresh() {
        tokenRefreshTimer?.invalidate()
        tokenRefreshTimer = nil
        print("🛑 Automatic token refresh stopped")
    }
    
    // MARK: - Offline Support
    
    /// Check if we can work offline
    func canWorkOffline() -> Bool {
        return hasValidStoredSession() && user != nil
    }
    
    /// Get offline status message
    func getOfflineStatusMessage() -> String {
        if isOffline {
            return "Working offline - some features may be limited"
        } else {
            return "Connected to server"
        }
    }
    
    /// Manually trigger token refresh (useful for testing or user-initiated refresh)
    func manualTokenRefresh() async {
        print("🔄 Manual token refresh initiated")
        await refreshTokensIfNeeded()
    }
    
    /// Check if tokens are expired and need refresh
    func checkTokenStatus() -> (isExpired: Bool, willExpireSoon: Bool, canRefresh: Bool) {
        guard let session = session else {
            // Try to get from Keychain
            if let storedTokens = try? keychainManager.retrieveSession() {
                return (storedTokens.isExpired, storedTokens.willExpireSoon, true)
            }
            return (true, false, false)
        }
        
        let tokens = SessionTokens(from: session)
        return (tokens.isExpired, tokens.willExpireSoon, true)
    }
    
    // Temporarily disabled due to syntax issues with authStateChanges
    func setupAuthListener() {
        Task {
            // await the AsyncStream itself
            let stream = await supabaseClient.auth.authStateChanges

            for await (_, session) in stream {
                await MainActor.run {
                    if let session = session {
                        self.user = session.user
                        self.session = session
                        self.authState = .Dashboard
                        self.isOffline = false
                        
                        // Store the session in Keychain
                        self.storeSession(session)
                        
                        // Set up automatic token refresh
                        self.setupAutomaticTokenRefresh()
                    } else {
                        self.user = nil
                        self.session = nil
                        self.authState = .signIn
                        self.isOffline = false
                        
                        // Stop automatic token refresh
                        self.stopAutomaticTokenRefresh()
                        
                        // Clear Keychain data
                        try? self.keychainManager.clearAllData()
                    }
                }
            }
        }
    }
}
