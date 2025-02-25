//
//  UserRecord.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 25/02/2025.
//

struct UserRecord: Identifiable, Codable {
    var id: String { user_id }
    
    let user_id: String
    let username: String
    let created_at: String?
}
