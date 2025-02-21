//
//  ScanRecord.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 20/02/2025.
//

import SwiftUI

struct ScanRecord: Identifiable, Codable {
    var id: String { scan_id }
    let scan_id: String
    let height: Double
    let diameter: Double
    let species: String
    let scan_time: String
}
