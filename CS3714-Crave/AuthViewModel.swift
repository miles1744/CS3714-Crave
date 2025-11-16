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

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var loading = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private let context: ModelContext
    private var authListener: AuthStateDidChangeListenerHandle?

    init(context: ModelContext) {
        self.context = context
        // Observe auth state
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            self.isAuthenticated = (user != nil)
            if let u = user {
                Task { await self.pullUserProfile(uid: u.uid) }
            }
        }
    }

    deinit {
        if let l = authListener { Auth.auth().removeStateDidChangeListener(l) }
    }

    // MARK: - Auth actions

    func signUp(email: String, password: String, displayName: String?, userType: String) async {
        loading = true
        errorMessage = nil
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            // Create Firestore user doc
            try await db.collection("users").document(result.user.uid).setData([
                "uid": result.user.uid,
                "email": email,
                "displayName": displayName as Any,
                "userType": userType
            ], merge: true)
            try? await result.user.sendEmailVerification()
            await pullUserProfile(uid: result.user.uid)
        } catch {
            errorMessage = error.localizedDescription
        }
        loading = false
    }

    func signIn(email: String, password: String) async {
        loading = true; errorMessage = nil
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            await pullUserProfile(uid: result.user.uid)
        } catch {
            errorMessage = error.localizedDescription
        }
        loading = false
    }

    func signOut() {
        do { try Auth.auth().signOut() } catch { errorMessage = error.localizedDescription }
    }

    // MARK: - Firestore → SwiftData

    private func pullUserProfile(uid: String) async {
        do {
            let snap = try await db.collection("users").document(uid).getDocument()
            guard let data = snap.data() else { return }
            let email = (data["email"] as? String) ?? ""
            let name  = data["displayName"] as? String
            let userType = data["userType"] as? String ?? "General User"

            // Upsert in SwiftData
            let descriptor = FetchDescriptor<UserProfile>(predicate: #Predicate { $0.uid == uid })
            if let existing = try? context.fetch(descriptor).first {
                existing.email = email
                existing.displayName = name
                existing.userType = userType
            } else {
                context.insert(UserProfile(uid: uid, email: email, displayName: name, userType: userType))
            }
            try? context.save()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // Optional: local edit that also pushes to Firestore
    func updateDisplayName(_ newName: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try await db.collection("users").document(uid).setData(["displayName": newName], merge: true)
            await pullUserProfile(uid: uid)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
