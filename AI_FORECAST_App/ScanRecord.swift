//
//  ScanRecord.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 20/02/2025.
//

import Foundation

struct ScanRecord: Codable {
    let scan_id: String       // Will store UUID
    let height: Double
    let diameter: Double
    let species: String
    let scan_time: Date
}
