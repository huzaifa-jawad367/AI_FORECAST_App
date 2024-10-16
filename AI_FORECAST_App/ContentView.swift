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
    
    var body: some View {
        ZStack {

            switch authState {
            case .signIn:
                SignInView(authState: $authState)
            case .signUp:
                SignUpView(authState: $authState)
            case .Dashboard: 
                DashBoardView(authState: $authState)
            }
            
        }
        
    }
}



#Preview {
    ContentView()
}


