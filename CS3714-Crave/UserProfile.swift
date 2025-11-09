//
//  UserProfile.swift
//  CS3714-Crave
//
//  Created by Brendan Michael Riordan on 11/9/25.
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var uid: String
    var email: String
    var displayName: String?

    init(uid: String, email: String, displayName: String? = nil) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
    }
}

// Mirror of Firestore data for decoding/encoding if needed
struct FirestoreUser: Codable {
    let uid: String
    let email: String
    let displayName: String?
}
