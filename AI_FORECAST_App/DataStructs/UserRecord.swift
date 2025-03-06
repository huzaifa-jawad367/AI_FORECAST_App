//
//  UserRecord.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 25/02/2025.
//

struct UserRecord: Identifiable, Codable {
    var id: String { user_id }
    
    var user_id: String
    var username: String
    var email: String
    var created_at: String? = "-"
    var profile_picture_url: String?
}
