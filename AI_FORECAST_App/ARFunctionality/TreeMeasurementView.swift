//
//  TreeMeasurementView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 05/02/2025.
//

//import SwiftUI
//import RealityKit
//import Combine
//
//struct TreeMeasurementView: View {
//    @State private var arView: CustomARView?
//    @Binding var authState: AuthState
//    
//    @State private var distance: Float = 0.0
//    private let distanceTimer = Timer.publish(every: 0.1, on: .main, in: .common)
//                                           .autoconnect()
//    
//    private let steps = ["Trunk", "Walk", "Base", "Top"]
//    
//    var body: some View {
//        ZStack {
//            // AR background
//            CustomARViewRepresentable(arView: $arView)
//                .ignoresSafeArea()
//            
//            // Top step indicator…
//            VStack {
//                HStack {
//                    let refDone  = ARManager.shared.referencePoint != nil
//                    let walkDone = refDone && (3.0...5.0).contains(distance)
//                    let baseDone = ARManager.shared.bottomPoint != nil
//                    let topDone  = ARManager.shared.topPoint != nil
//                    let statuses = [refDone, walkDone, baseDone, topDone]
//                    
//                    ForEach(0..<steps.count, id: \.self) { idx in
//                        VStack(spacing: 4) {
//                            Circle()
//                                .fill(statuses[idx] ? Color.green : Color.gray)
//                                .frame(width: 20, height: 20)
//                            Text(steps[idx])
//                                .font(.caption2)
//                                .foregroundColor(.white)
//                        }
//                        if idx < steps.count-1 { Spacer() }
//                    }
//                }
//                .padding(.horizontal, 40)
//                .padding(.top, 60)
//                Spacer()
//            }
//            .ignoresSafeArea(edges: .top)
//            
//            // Center crosshair
//            GeometryReader { geo in
//                Path { path in
//                    let midX = geo.size.width/2
//                    let midY = geo.size.height/2
//                    let len: CGFloat = 15
//                    path.move(to: CGPoint(x: midX-len, y: midY))
//                    path.addLine(to: CGPoint(x: midX+len, y: midY))
//                    path.move(to: CGPoint(x: midX, y: midY-len))
//                    path.addLine(to: CGPoint(x: midX, y: midY+len))
//                }
//                .stroke(Color.red, lineWidth: 2)
//                .allowsHitTesting(false)
//            }
//            .ignoresSafeArea()
//            
//            // Bottom controls
//            VStack {
//                Spacer()
//                HStack(spacing: 20) {
//                    // Home
//                    Button { authState = .Dashboard } label: {
//                        Image(systemName: "house.fill")
//                          .resizable().frame(width:40, height:40)
//                          .padding(10).background(Circle().fill(Color.blue))
//                          .foregroundColor(.white).shadow(radius:5)
//                    }
//                    
//                    // Capture (center tap)
//                    Button {
//                        print("Place marker button pressed!")
//                        ARManager.shared.actionStream.send(.placeBlock(color: Color.green)) // Green Colour
//                    } label: {
//                        Image(systemName: "camera.circle.fill")
//                          .resizable().frame(width:80, height:80)
//                          .padding(10).background(Circle().fill(Color.blue))
//                          .foregroundColor(.white).shadow(radius:10)
//                    }
////                    .disabled(!(3.0...5.0).contains(distance))
////                    .opacity((3.0...5.0).contains(distance) ? 1 : 0.5)
//                    
//                    // Distance read‑out
//                    ZStack {
//                        Circle()
//                          .fill(Color.blue).frame(width:60, height:60)
//                          .shadow(radius:5)
//                        Text(String(format: "%.1f m", distance))
//                          .font(.headline).foregroundColor(.white)
//                    }
//                    
//                }
//                .padding(.bottom, 40)
//            }
//        }
//        
//    }
//}
//
//#Preview {
//    TreeMeasurementView(authState: .constant(.scanPage))
//}


import SwiftUI
import RealityKit
import Combine

struct TreeMeasurementView: View {
    @Binding var authState: AuthState
    
    @StateObject private var arManager = ARManager.shared
    
    @State private var scannedHeight: Double = 0
    @State private var goToResult = false
    @State private var arView: CustomARView?
    @State private var distance: Float = 0.0
    private let distanceTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    private let steps = ["Trunk", "Walk", "Base", "Top"]
    
    @State private var scannedImage: UIImage? = nil
    @State private var scannedTimestamp = Date()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - AR View
                CustomARViewRepresentable()
                    .ignoresSafeArea()
                
                // MARK: - Step Indicator
                VStack {
                    HStack {
                        let refDone  = arManager.referencePoint != nil
                        let walkDone = refDone && (3.0...5.0).contains(distance)
                        let baseDone = arManager.bottomPoint != nil
                        let topDone  = arManager.topPoint != nil
                        let statuses = [refDone, walkDone, baseDone, topDone]
                        
                        ForEach(0..<steps.count, id: \.self) { idx in
                            VStack(spacing: 4) {
                                Circle()
                                    .fill(statuses[idx] ? Color.green : Color.gray)
                                    .frame(width: 20, height: 20)
                                Text(steps[idx])
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            }
                            if idx < steps.count - 1 { Spacer() }
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 60)
                    Spacer()
                }
                .ignoresSafeArea(edges: .top)
                
                // MARK: - Crosshair Overlay
                GeometryReader { geo in
                    Path { path in
                        let midX = geo.size.width / 2
                        let midY = geo.size.height / 2
                        let len: CGFloat = 15
                        path.move(to: CGPoint(x: midX - len, y: midY))
                        path.addLine(to: CGPoint(x: midX + len, y: midY))
                        path.move(to: CGPoint(x: midX, y: midY - len))
                        path.addLine(to: CGPoint(x: midX, y: midY + len))
                    }
                    .stroke(Color.red, lineWidth: 2)
                    .allowsHitTesting(false)
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
                        
                        // Capture Button
                        Button {
                            ARManager.shared.actionStream.send(.placeNextTreeMarker)
                        } label: {
                            Image(systemName: "camera.circle.fill")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Circle().fill(Color.blue))
                                .shadow(radius: 10)
                        }
                        //                    .disabled(!(3.0...5.0).contains(distance))
                        //                    .opacity((3.0...5.0).contains(distance) ? 1 : 0.5)
                        
//                        // Distance Display
//                        ZStack {
//                            Circle()
//                                .fill(Color.blue)
//                                .frame(width: 60, height: 60)
//                                .shadow(radius: 5)
//                            Text(String(format: "%.1f m", distance))
//                                .font(.headline)
//                                .foregroundColor(.white)
//                        }
                        
                        // Reset Button
                        Button {
                            ARManager.shared.actionStream.send(.removeAllAnchors)
                        } label: {
                            Image(systemName: "trash")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Circle().fill(Color.blue))
                                .shadow(radius: 5)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .onReceive(ARManager.shared.actionStream) { action in
                if case .showHeight(let h) = action {
                    scannedHeight    = h
                    scannedTimestamp = Date()
                    
                    if let arView = arView {
                        arView.snapshot(saveToHDR: false) { image in
                            DispatchQueue.main.async {
                                scannedImage = image ?? UIImage()
                                goToResult   = true
                            }
                        }
                    } else {
                        scannedImage = UIImage()
                        goToResult   = true
                    }
                }
            }
            // this replaces the old NavigationLink(isActive:) approach:
            .navigationDestination(isPresented: $goToResult) {
                ScanResultView(
                    image:     scannedImage ?? UIImage(),
                    height:    scannedHeight,
                    timestamp: scannedTimestamp,
                    authState: $authState
                )
            }
            
            //        .onReceive(distanceTimer) { _ in
            //            guard let ref = ARManager.shared.referencePoint,
            //                  let cam = arView?.cameraTransform else { return }
            //            let d = simd_distance(ref, cam.translation)
            //            distance = d
            //            ARManager.shared.actionStream.send(.updateDistance(d))
            //        }
        }
    }
}


#Preview {
    TreeMeasurementView(authState: .constant(.scanPage))
}
