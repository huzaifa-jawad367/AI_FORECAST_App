//
//  KeychainManager.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 27/08/2025.
//

import Foundation
import KeychainAccess
import Supabase

struct SessionTokens: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
    let userId: String
    
    init(from session: Session) {
        self.accessToken = session.accessToken
        self.refreshToken = session.refreshToken
//        self.expiresAt = session.expiresAt
        self.expiresAt = Date(timeIntervalSince1970: session.expiresAt ?? 0)
        self.userId = session.user.id.uuidString
    }
    
    var isExpired: Bool {
        return Date() > expiresAt
    }
    
    var willExpireSoon: Bool {
        // Consider token expired if it expires within the next 5 minutes
        return Date().addingTimeInterval(300) > expiresAt
    }
}

class KeychainManager {
    static let shared = KeychainManager()
    
    private let keychain: Keychain
    private let sessionKey = "supabase_session"
    private let userDataKey = "user_data"
    
    private init() {
        // Initialize Keychain with your app's bundle identifier
        self.keychain = Keychain(service: "com.huzaifa-jawad367.AI-FORECAST-App")
            .accessibility(.whenUnlockedThisDeviceOnly)
            .synchronizable(false)
    }
    
    // MARK: - Session Token Management
    
    /// Store session tokens in Keychain
    func storeSession(_ session: Session) throws {
        let tokens = SessionTokens(from: session)
        
        do {
            let data = try JSONEncoder().encode(tokens)
            try keychain.set(data, key: sessionKey)
            print("✅ Session tokens stored in Keychain successfully")
        } catch {
            print("❌ Failed to store session in Keychain: \(error.localizedDescription)")
            throw KeychainError.storageFailed(error)
        }
    }
    
    /// Retrieve session tokens from Keychain
    func retrieveSession() throws -> SessionTokens? {
        do {
            guard let data = try keychain.getData(sessionKey) else {
                print("ℹ️ No session found in Keychain")
                return nil
            }
            
            let tokens = try JSONDecoder().decode(SessionTokens.self, from: data)
            print("✅ Session tokens retrieved from Keychain successfully")
            return tokens
        } catch {
            print("❌ Failed to retrieve session from Keychain: \(error.localizedDescription)")
            throw KeychainError.retrievalFailed(error)
        }
    }
    
    /// Clear session tokens from Keychain
    func clearSession() throws {
        do {
            try keychain.remove(sessionKey)
            print("✅ Session tokens cleared from Keychain successfully")
        } catch {
            print("❌ Failed to clear session from Keychain: \(error.localizedDescription)")
            throw KeychainError.deletionFailed(error)
        }
    }
    
    // MARK: - User Data Management
    
    /// Store user data in Keychain for offline access
    func storeUserData(_ user: User) throws {
        do {
            let data = try JSONEncoder().encode(user)
            try keychain.set(data, key: userDataKey)
            print("✅ User data stored in Keychain successfully")
        } catch {
            print("❌ Failed to store user data in Keychain: \(error.localizedDescription)")
            throw KeychainError.storageFailed(error)
        }
    }
    
    /// Retrieve user data from Keychain
    func retrieveUserData() throws -> User? {
        do {
            guard let data = try keychain.getData(userDataKey) else {
                print("ℹ️ No user data found in Keychain")
                return nil
            }
            
            let user = try JSONDecoder().decode(User.self, from: data)
            print("✅ User data retrieved from Keychain successfully")
            return user
        } catch {
            print("❌ Failed to retrieve user data from Keychain: \(error.localizedDescription)")
            throw KeychainError.retrievalFailed(error)
        }
    }
    
    /// Clear user data from Keychain
    func clearUserData() throws {
        do {
            try keychain.remove(userDataKey)
            print("✅ User data cleared from Keychain successfully")
        } catch {
            print("❌ Failed to clear user data from Keychain: \(error.localizedDescription)")
            throw KeychainError.deletionFailed(error)
        }
    }
    
    // MARK: - Utility Methods
    
    /// Check if session exists in Keychain
    func hasStoredSession() -> Bool {
        do {
            let data = try keychain.getData(sessionKey)
            return data != nil
        } catch {
            return false
        }
    }
    
    /// Check if stored session is valid (not expired)
    func hasValidStoredSession() -> Bool {
        do {
            guard let tokens = try retrieveSession() else {
                return false
            }
            return !tokens.isExpired
        } catch {
            return false
        }
    }
    
    /// Clear all app data from Keychain
    func clearAllData() throws {
        do {
            try clearSession()
            try clearUserData()
            print("✅ All Keychain data cleared successfully")
        } catch {
            print("❌ Failed to clear all Keychain data: \(error.localizedDescription)")
            throw error
        }
    }
}

// MARK: - Custom Errors

enum KeychainError: LocalizedError {
    case storageFailed(Error)
    case retrievalFailed(Error)
    case deletionFailed(Error)
    case encodingFailed(Error)
    case decodingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .storageFailed(let error):
            return "Failed to store data in Keychain: \(error.localizedDescription)"
        case .retrievalFailed(let error):
            return "Failed to retrieve data from Keychain: \(error.localizedDescription)"
        case .deletionFailed(let error):
            return "Failed to delete data from Keychain: \(error.localizedDescription)"
        case .encodingFailed(let error):
            return "Failed to encode data: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        }
    }
}
