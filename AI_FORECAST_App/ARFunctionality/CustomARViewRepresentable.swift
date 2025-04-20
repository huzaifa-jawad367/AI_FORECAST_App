//
//  CustomARViewRepresentable.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 09/10/2024.
//

import SwiftUI
import RealityKit

struct CustomARViewRepresentable: UIViewRepresentable {
//    @Binding var arView: CustomARView?

    func makeUIView(context: Context) -> CustomARView {
//        return CustomARView(frame: UIScreen.main.bounds)
        return CustomARView()
    }

    func updateUIView(_ uiView: CustomARView, context: Context) {
//        // Defer the binding update until after SwiftUI’s update pass
//        DispatchQueue.main.async {
//            self.arView = uiView
//        }
    }
}



