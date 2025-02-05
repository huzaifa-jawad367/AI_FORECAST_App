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

    var body: some View {
        ZStack {
            CustomARViewRepresentable()
                .ignoresSafeArea()
            
            VStack {
                Spacer()

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
                .padding(.bottom, 40)
            }
        }
    }
}
