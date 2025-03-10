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


struct ScanPageView: View {
    
    @Binding var authState: AuthState
    
    var body: some View {
        Text("Hello").font(.largeTitle)
    }
}


struct ContentView : View {
    
    @State private var authState: AuthState = .signIn
    @StateObject private var sessionManager = SessionManager()
    
    var body: some View {
        ZStack {

            switch authState {
            case .signIn:
                SignInView(authState: $authState)
            case .signUp:
                SignUpView(authState: $authState)
            case .Dashboard: 
                DashBoardView(authState: $authState)
            case .ScansList:
                ScansListView(authState: $authState)
            case .ProjectsList:
                ProjectListView(authState: $authState)
            case .Settings:
                SettingsView(authState: $authState)
            case .Guide:
                BiomassGuideView(authState: $authState)
            case .CreateProject:
                SettingsView(authState: $authState)
            case .ScanResultView:
                ScanResultView(
                    image: UIImage(systemName: "leaf")!, // Placeholder image
                    height: 12.5,
                    diameter: 30.2,
                    timestamp: Date(),
                    authState: $authState
                )
            case .scanPage:
                CustomARViewRepresentable()
            }
            
        }
        .environmentObject(sessionManager)
    }
    
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SessionManager())
    }
}

