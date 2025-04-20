//
//  ARAction.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 17/10/2024.
//

//import SwiftUI
//import RealityKit
//
//enum ARAction {
////    case placeMarker(type: MarkerType, transform: simd_float4x4)
////    case removeAllMarkers
//    case removeAllAnchors
////    case updateDistance(_ meters: Float)
////    case showHeight(_ meters: Float)
//    case placeBlock(color: Color)
//}
//
//
//enum MarkerType {
//    case treeReference
//    case base
//    case top
//
//    var color: Color {
//        switch self {
//        case .treeReference:
//            return .green
//        case .base, .top:
//            return .red
//        }
//    }
//}


import SwiftUI

enum ARAction {
    case placeBlock(color: Color)
    case placeSphere(color: Color)
    case removeAllAnchors
}
