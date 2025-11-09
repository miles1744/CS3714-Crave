//
//  DemoAuth.swift
//  CS3714-Crave
//
//  Created by Brendan Michael Riordan on 11/9/25.
//

import FirebaseAuth

func demoAuth() {
    Task {
        do {
            // Sign up (use a fresh email once)
            let result = try await Auth.auth().createUser(withEmail: "test@example.com", password: "password123")
            print("Created user:", result.user.uid)

            // Or sign in (subsequent runs)
            // let result = try await Auth.auth().signIn(withEmail: "test@example.com", password: "password123")
            // print("Signed in:", result.user.uid)
        } catch {
            print("Auth error:", error.localizedDescription)
        }
    }
}
