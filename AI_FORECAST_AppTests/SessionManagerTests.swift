//
//  SessionManagerTests.swift
//  AI_FORECAST_AppTests
//
//  Created by Huzaifa Jawad on 17/02/2025.
//

import XCTest
import SwiftUI
@testable import AI_FORECAST_App

class SessionManagerTests: XCTestCase {
    
    var sessionManager: SessionManager!
    
    override func setUp() {
        super.setUp()
        sessionManager = SessionManager()
    }
    
    override func tearDown() {
        sessionManager = nil
        super.tearDown()
    }
    
    // MARK: - Session Restoration Tests
    
    func testRestoreSessionWithValidSession() async {
        // Given: A valid session exists
        // Note: This would require mocking Supabase client
        
        // When: restoreSession is called
        await sessionManager.restoreSession()
        
        // Then: User should be logged in and auth state should be Dashboard
        XCTAssertNotNil(sessionManager.user)
        XCTAssertEqual(sessionManager.authState, .Dashboard)
    }
    
    func testRestoreSessionWithNoSession() async {
        // Given: No valid session exists
        
        // When: restoreSession is called
        await sessionManager.restoreSession()
        
        // Then: User should be nil and auth state should be signIn
        XCTAssertNil(sessionManager.user)
        XCTAssertEqual(sessionManager.authState, .signIn)
    }
    
    // MARK: - Auth State Tests
    
    func testInitialAuthState() {
        // Given: Fresh SessionManager
        
        // Then: Should start with signIn state
        XCTAssertEqual(sessionManager.authState, .signIn)
        XCTAssertNil(sessionManager.user)
    }
    
    func testIsSignedInProperty() {
        // Given: No user
        XCTAssertFalse(sessionManager.isSignedIn)
        
        // When: User is set
        // Note: This would require creating a mock User object
        
        // Then: isSignedIn should be true
        // XCTAssertTrue(sessionManager.isSignedIn)
    }
    
    // MARK: - Logout Tests
    
    func testSignOut() async {
        // Given: User is signed in
        // Note: Would need to mock a signed-in state
        
        // When: signOut is called
        do {
            try await sessionManager.signOut()
            
            // Then: User should be nil and auth state should be signIn
            XCTAssertNil(sessionManager.user)
            XCTAssertEqual(sessionManager.authState, .signIn)
        } catch {
            XCTFail("Sign out should not throw error: \(error)")
        }
    }
    
    // MARK: - Auth Listener Tests
    
    func testAuthListenerSetup() {
        // Given: SessionManager is initialized
        
        // Then: Auth listener should be set up
        // Note: This would require checking if the listener is active
        // This is more of an integration test
    }
    
    // MARK: - Thread Safety Tests
    
    func testMainActorUpdates() {
        // Given: SessionManager is on main actor
        
        // When: Updating published properties
        sessionManager.authState = .Dashboard
        
        // Then: Should not crash
        XCTAssertEqual(sessionManager.authState, .Dashboard)
    }
    
    // MARK: - Keychain Integration Tests
    
    func testKeychainSessionStorage() {
        // Given: SessionManager with Keychain integration
        
        // When: Checking if we can work offline
        let canWorkOffline = sessionManager.canWorkOffline()
        
        // Then: Should return appropriate value based on stored session
        // This will be false initially since no session is stored
        XCTAssertFalse(canWorkOffline)
    }
    
    func testHasValidStoredSession() {
        // Given: SessionManager with Keychain integration
        
        // When: Checking for valid stored session
        let hasValidSession = sessionManager.hasValidStoredSession()
        
        // Then: Should return false initially (no stored session)
        XCTAssertFalse(hasValidSession)
    }
    
    func testOfflineStatusMessage() {
        // Given: SessionManager in online mode
        
        // When: Getting offline status message
        let message = sessionManager.getOfflineStatusMessage()
        
        // Then: Should indicate connected status
        XCTAssertEqual(message, "Connected to server")
        
        // When: Setting offline mode
        sessionManager.isOffline = true
        
        // Then: Should indicate offline status
        XCTAssertEqual(sessionManager.getOfflineStatusMessage(), "Working offline - some features may be limited")
    }
    
    func testTokenStatusCheck() {
        // Given: SessionManager with no session
        
        // When: Checking token status
        let status = sessionManager.checkTokenStatus()
        
        // Then: Should indicate no valid session
        XCTAssertTrue(status.isExpired)
        XCTAssertFalse(status.canRefresh)
    }
    
    func testManualTokenRefresh() async {
        // Given: SessionManager
        
        // When: Manually triggering token refresh
        await sessionManager.manualTokenRefresh()
        
        // Then: Should not crash (even with no session)
        // This is more of an integration test to ensure the method works
    }
    
    func testCanWorkOffline() {
        // Given: SessionManager with no stored session
        
        // When: Checking if can work offline
        let canWorkOffline = sessionManager.canWorkOffline()
        
        // Then: Should return false initially
        XCTAssertFalse(canWorkOffline)
    }
    
    // MARK: - Error Handling Tests
    
    func testNetworkErrorHandling() async {
        // Given: Network error scenario
        // Note: Would need to mock network failures
        
        // When: restoreSession with network error
        
        // Then: Should handle gracefully and set auth state to signIn
        await sessionManager.restoreSession()
        XCTAssertEqual(sessionManager.authState, .signIn)
    }
    
    // MARK: - Integration Tests
    
    func testFullAuthFlow() async {
        // Given: Fresh app state
        
        // When: Complete auth flow
        // 1. Restore session (should fail)
        await sessionManager.restoreSession()
        XCTAssertEqual(sessionManager.authState, .signIn)
        
        // 2. Sign out (should work)
        do {
            try await sessionManager.signOut()
            XCTAssertEqual(sessionManager.authState, .signIn)
        } catch {
            XCTFail("Sign out failed: \(error)")
        }
    }
}

// MARK: - Mock Objects for Testing

class MockSupabaseClient {
    var shouldReturnValidSession = false
    var shouldThrowError = false
    
    func session() async throws -> Session? {
        if shouldThrowError {
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }
        
        if shouldReturnValidSession {
            // Return mock session
            return nil // Placeholder
        }
        
        return nil
    }
}

// MARK: - Test Helpers

extension SessionManagerTests {
    
    func createMockUser() -> User {
        // Create a mock User object for testing
        // This would depend on your User model structure
        fatalError("Implement based on your User model")
    }
    
    func simulateNetworkError() {
        // Simulate network connectivity issues
        // This would require mocking the network layer
    }
} 