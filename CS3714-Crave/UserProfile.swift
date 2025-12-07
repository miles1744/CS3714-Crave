//
//  UserProfile.swift
//  CS3714-Crave
//
//  Created by Brendan Michael Riordan on 11/9/25.
//

import Foundation
import SwiftData

/// SwiftData model class for storing user profiles locally
@Model
final class UserProfile {
    @Attribute(.unique) var uid: String     // Firebase UID (unique per user)
    var email: String                       // User's email address
    var displayName: String?                // Optional display name (can be edited)
    var userType: String                    // Either "General User" or "Chef"

    /// Initializer for UserProfile model
    init(
        uid: String,
        email: String,
        displayName: String? = nil,
        userType: String = "General User"
    ) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
        self.userType = userType
    }
}

/// Codable struct used to send/receive user profile data to/from Firestore
struct FirestoreUser: Codable {
    let uid: String               // Firebase UID
    let email: String             // User's email
    let displayName: String?      // Optional name
    let userType: String?         // "General User" or "Chef"
}
