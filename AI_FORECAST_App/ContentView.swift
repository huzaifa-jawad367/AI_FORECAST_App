//
//  ContentView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 9/16/24.
//

import SwiftUI
import RealityKit
import ARKit
import UIKit

struct ContentView: View {
    // @State private var authState: AuthState = .signIn
    @State private var showSplash: Bool = true
//    @StateObject private var sessionManager = SessionManager()
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        ZStack {
            // Show SplashScreenView first
            if showSplash {
                SplashScreenView()
            } else {
                // Then show the main content based on authState
                switch sessionManager.authState {
                case .signIn:
                    SignInView(authState: $sessionManager.authState)
                case .signUp:
                    SignUpView(authState: $sessionManager.authState)
                case .Dashboard:
                    DashBoardView(authState: $sessionManager.authState)
                case .ScansList:
                    ScansListView(authState: $sessionManager.authState, projectID: "16089a3d-ca0d-4e73-ace4-ff4813bb9f0b")
                case .ProjectsList:
                    ProjectListView(authState: $sessionManager.authState)
                case .Settings:
                    SettingsView(authState: $sessionManager.authState)
                case .Guide:
                    BiomassGuideView(authState: $sessionManager.authState)
                case .CreateProject:
                    SettingsView(authState: $sessionManager.authState)
                case .ScanResultView:
                    ScanResultView(
                        image: UIImage(systemName: "leaf")!, // Placeholder image
                        height: 12.5,
                        timestamp: Date(),
                        authState: $sessionManager.authState
                    )
                case .scanPage:
                    TreeMeasurementView (authState: $sessionManager.authState)
                case .resetPasswordFlow:
                    NewPasswordView(authState: $sessionManager.authState)
                        .onAppear { print("🔑 NewPasswordView") }
                }
            }
        }
        .environmentObject(sessionManager)
        .onAppear {
            // Display splash screen for 2 seconds, then switch to the Sign In view
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    showSplash = false
                }
            }
        }
//        .onOpenURL { url in
//            print("🔑 onOpenURL: \(url)")
//            guard url.host == "reset-password" else { return }
//            authState = .resetPasswordFlow
//
//            Task {
//                do {
//                    // this is async and will throw on error
//                    print("🔑 Attempting to restore session from URL: \(url)")
//                    _ = try await sessionManager
//                            .supabaseClient
//                            .auth
//                            .session(from: url) 
//
//                    print("✅ Session restored")
//                    // authState = .resetPasswordFlow
//
//                } catch {
//                    print("❌ Failed to restore session:", error.localizedDescription)
//                }
//            }
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SessionManager())
    }
}

