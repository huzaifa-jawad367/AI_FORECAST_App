//
//  TreeMeasurementView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 05/02/2025.
//


import Foundation
import SwiftUI

struct TreeMeasurementView: View {
    /// Hold a reference to the one true ARView instance
    @State private var arView: CustomARView?
    
    /// Binding back to your navigation/auth state
    @Binding var authState: AuthState

    var body: some View {
        ZStack {
            // MARK: - AR View
            CustomARViewRepresentable(arView: $arView)
                .ignoresSafeArea()

            // MARK: - Crosshair Overlay
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
                .allowsHitTesting(false)     // Pass taps through to ARView
            }
            .ignoresSafeArea()

            // MARK: - Bottom Controls
            VStack {
                Spacer()
                HStack(spacing: 20) {
                    // Home Button
                    Button {
                        authState = .Dashboard
                    } label: {
                        Image(systemName: "house.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Circle().fill(Color.blue))
                            .shadow(radius: 5)
                    }

                    // Manual Capture Button
                    Button {
                        // Simulate a tap on the actual ARView
                        arView?.handleTap(UITapGestureRecognizer())
                    } label: {
                        Image(systemName: "camera.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Circle().fill(Color.blue))
                            .shadow(radius: 10)
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    TreeMeasurementView(authState: .constant(.scanPage))
}


