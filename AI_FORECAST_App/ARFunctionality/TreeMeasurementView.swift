//
//  TreeMeasurementView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 05/02/2025.
//


import SwiftUI
import RealityKit
import Combine

struct TreeMeasurementView: View {
    /// Hold a reference to the one true ARView instance
    @State private var arView: CustomARView?
    /// Binding back to your navigation/auth state
    @Binding var authState: AuthState
    /// Live distance from camera to reference point
    @State private var distance: Float = 0.0

    // Timer for updating distance
    private let distanceTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    // Steps for the top indicator
    private let steps = ["Trunk", "Walk", "Base", "Top"]
    
    var body: some View {
        ZStack {
            // MARK: - AR View
            CustomARViewRepresentable(arView: $arView)
                .ignoresSafeArea()
            
            VStack {
                ZStack {
                    // Underline
                    Rectangle()
                        .fill(Color.gray)
                        .frame(height: 2)
                        .padding(.horizontal, 40)

                    // Circles + labels
                    HStack {
                        // Compute completion statuses
                        let refDone = ARManager.shared.referencePoint != nil
                        let walkDone = refDone && distance >= 3.0
                        let baseDone = ARManager.shared.bottomPoint != nil
                        let topDone = ARManager.shared.topPoint != nil
                        let statuses = [refDone, walkDone, baseDone, topDone]

                        ForEach(0..<steps.count, id: \ .self) { index in
                            VStack(spacing: 4) {
                                Circle()
                                    .fill(statuses[index] ? Color.green : Color.gray)
                                    .frame(width: 20, height: 20)
                                Text(steps[index])
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            }

                            if index < steps.count - 1 {
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.top, 60)

                Spacer()
            }
            .ignoresSafeArea(edges: .top)

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

                    // Distance Display
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 60, height: 60)
                            .shadow(radius: 5)
                        Text(String(format: "%.1f m", distance))
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        // Update distance on timer
        .onReceive(distanceTimer) { _ in
            // Compute only if reference point and ARView are available
            guard let refPoint = ARManager.shared.referencePoint,
                  let camTransform = arView?.cameraTransform else { return }
            let camPos = camTransform.translation
            distance = simd_distance(refPoint, camPos)
        }
    }
}

#Preview {
    TreeMeasurementView(authState: .constant(.scanPage))
}


