//
//  CustomARView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 09/10/2024.
//

import ARKit
import RealityKit
import SwiftUI

class CustomARView: ARView {
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
    }
    
    dynamic required init? (coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemted ")
    }
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds )
    }
}


