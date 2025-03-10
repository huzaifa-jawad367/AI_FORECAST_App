//
//  SplashScreenView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 10/03/2025.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            // MARK: - Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.topBlue,  // Top color
                    Color.bottomBlue                // Bottom color
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            // MARK: - Logo & Text
            VStack(spacing: 10) {
                // Replace with an Image if you have a custom logo asset
                Text("AI-ForCaST")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Revolutionizing Forest \nSurveys with AR Precision")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
        }
    }

}

extension Color {
    static let topBlue = Color(red: 106/255, green: 150/255, blue: 219/255)  // #6b96db
    static let bottomBlue = Color(red: 41/255, green: 83/255, blue: 156/255) // #29539c
}


#Preview {
    SplashScreenView()
}
