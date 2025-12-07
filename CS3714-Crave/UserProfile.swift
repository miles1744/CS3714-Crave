//
//  UserProfile.swift
//  CS3714-Crave
//
//  Created by Brendan Michael Riordan on 11/9/25.
//

import Foundation
import SwiftData

//class for User Profiles.
@Model
final class UserProfile {
    @Attribute(.unique) var uid: String
    var email: String
    var displayName: String?
    var userType: String          // "General User" or "Chef"

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

// struct for sending user profile to firebase
struct FirestoreUser: Codable {
    let uid: String
    let email: String
    let displayName: String?
    let userType: String?
}
