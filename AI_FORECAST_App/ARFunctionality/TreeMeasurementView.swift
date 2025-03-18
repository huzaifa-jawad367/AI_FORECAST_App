//
//  TreeMeasurementView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 05/02/2025.
//


import Foundation
import SwiftUI

struct TreeMeasurementView: View {
    
    var arView = CustomARView(frame: UIScreen.main.bounds) // Explicitly provide frame
    @Binding var authState: AuthState
    
    var body: some View {
        ZStack {
            CustomARViewRepresentable()
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                let midX = geometry.size.width / 2
                let midY = geometry.size.height / 2
                let crosshairLength: CGFloat = 15

                Path { path in
                    // Horizontal line
                    path.move(to: CGPoint(x: midX - crosshairLength, y: midY))
                    path.addLine(to: CGPoint(x: midX + crosshairLength, y: midY))

                    // Vertical line
                    path.move(to: CGPoint(x: midX, y: midY - crosshairLength))
                    path.addLine(to: CGPoint(x: midX, y: midY + crosshairLength))
                }
                .stroke(Color.red, lineWidth: 2)
                // Ensures the crosshair does NOT block taps
                .allowsHitTesting(false)
            }
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                HStack(spacing: 20) {
                    
                    Button(action: {
                        authState = .Dashboard
                        print("Navigating to dashboard...")
                    }) {
                        Image(systemName: "house.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Circle().fill(Color.blue))
                            .shadow(radius: 5)
                    }
                    
                    Button(action: {
                        DispatchQueue.main.async {
                            arView.handleTap(UITapGestureRecognizer()) // Simulate user tap
                        }
                    }) {
                        Image(systemName: "camera.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                            .background(Circle().fill(Color.blue))
                            .shadow(radius: 10)
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
}
