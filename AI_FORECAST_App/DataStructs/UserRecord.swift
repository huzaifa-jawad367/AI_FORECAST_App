//
//  UserRecord.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 25/02/2025.
//

//struct UserRecord: Identifiable, Codable {
//    var id: String { user_id }
//    
//    var user_id: String
//    var username: String
//    var email: String
//    var created_at: String? = "-"
//    var profile_picture_url: String?
//}

struct UserRecord: Identifiable, Codable {
    var id: String { user_id }
    
    var user_id: String
    var username: String
    var email: String?       // Marked as optional
    var created_at: String? = "-"
    var profile_picture_url: String?
    
    enum CodingKeys: String, CodingKey {
        case user_id = "id"         // Map JSON "id" to property user_id
        case username = "full_name" // Map JSON "full_name" to property username
        case email = "email"        // Email might not be returned; hence, optional
        case created_at
        case profile_picture_url
    }
}

