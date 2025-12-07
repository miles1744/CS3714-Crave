//
//  AuthViewModel.swift
//  CS3714-Crave
//
//  Created by Brendan Michael Riordan on 11/9/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftData

/// Main authentication + user-profile sync manager.
/// Handles Firebase Auth, Firestore user documents, and SwiftData persistence.
@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false          // Whether a Firebase user is logged in
    @Published var loading = false                  // For UI loading indicators
    @Published var errorMessage: String?            // Error message shown in UI
    @Published var currentProfile: UserProfile?     // Logged-in user's profile stored in SwiftData

    private let db = Firestore.firestore()          // Firestore reference
    private let context: ModelContext               // SwiftData context
    private var authListener: AuthStateDidChangeListenerHandle?  // Listener for auth state changes

    init(context: ModelContext) {
        self.context = context
        
        // Listen for Firebase authentication state updates
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            
            // Update authentication flag
            self.isAuthenticated = (user != nil)

            if let u = user {
                // If signed in, load the profile from Firestore → SwiftData
                Task { await self.pullUserProfile(uid: u.uid) }
            }
            else {
                // If signed out, clear the profile
                self.currentProfile = nil
            }
        }
    }

    deinit {
        // Remove Firebase auth listener when ViewModel deallocates
        if let l = authListener {
            Auth.auth().removeStateDidChangeListener(l)
        }
    }

    // MARK: - Auth actions

    /// Creates a new user in Firebase Auth + Firestore, then loads the profile.
    func signUp(
        email: String,
        password: String,
        displayName: String?,
        userType: String      // e.g. "General User" or "Chef"
    ) async {
        loading = true
        errorMessage = nil
        do {
            // Create user in Firebase Authentication
            let result = try await Auth.auth().createUser(
                withEmail: email,
                password: password
            )

            // Create or merge a Firestore user document
            try await db.collection("users").document(result.user.uid).setData([
                "uid": result.user.uid,
                "email": email,
                "displayName": displayName as Any,
                "userType": userType
            ], merge: true)

            // Send verification email (optional)
            try? await result.user.sendEmailVerification()

            // Pull and store profile locally
            await pullUserProfile(uid: result.user.uid)
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        loading = false
    }

    /// Signs in an existing Firebase user and loads profile.
    func signIn(email: String, password: String) async {
        loading = true
        errorMessage = nil
        do {
            let result = try await Auth.auth().signIn(
                withEmail: email,
                password: password
            )
            await pullUserProfile(uid: result.user.uid)
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        loading = false
    }

    /// Signs out the user and clears local profile.
    func signOut() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
            currentProfile = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Firestore → SwiftData synchronization

    /// Reads the Firestore user document, syncs it to SwiftData, and sets currentProfile.
    private func pullUserProfile(uid: String) async {
        do {
            // Fetch Firestore document
            let snap = try await db.collection("users").document(uid).getDocument()
            guard let data = snap.data() else { return }

            // Extract stored fields
            let email    = (data["email"] as? String) ?? ""
            let name     = data["displayName"] as? String
            let userType = (data["userType"] as? String) ?? "General User"

            // Fetch descriptor to check if SwiftData already has this user
            let descriptor = FetchDescriptor<UserProfile>(
                predicate: #Predicate { $0.uid == uid }
            )

            let profile: UserProfile

            // If a profile already exists in SwiftData, update it
            if let existing = try? context.fetch(descriptor).first {
                existing.email = email
                existing.displayName = name
                existing.userType = userType          // updating SwiftData userType
                profile = existing
            } else {
                // Otherwise create and insert a new SwiftData profile
                let newProfile = UserProfile(
                    uid: uid,
                    email: email,
                    displayName: name,
                    userType: userType                 //assigning initial userType
                )
                context.insert(newProfile)
                profile = newProfile
            }

            // Save SwiftData context changes
            try? context.save()

            // Set currentProfile for use across the app
            currentProfile = profile
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    /// Updates the display name in Firestore and pulls updated profile locally.
    func updateDisplayName(_ newName: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            // Push change to Firestore
            try await db.collection("users").document(uid)
                .setData(["displayName": newName], merge: true)

            // Refresh local profile
            await pullUserProfile(uid: uid)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
