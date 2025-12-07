//
//  AuthGateView.swift
//  CS3714-Crave
//
//  Created by Brendan Michael Riordan on 11/9/25.
//

import SwiftUI
import SwiftData

/// Top-level view that decides whether to show the home screen or authentication screens
struct AuthGateView: View {
    // Access the authentication view model from the environment
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        Group {
            // If the user is authenticated...
            if auth.isAuthenticated {
                // ...and the user profile has been loaded, show the HomeView
                if auth.currentProfile != nil {
                    HomeView()   // ✅ correct
                } else {
                    // Otherwise, show a loading spinner while profile is loading
                    ProgressView("Loading profile...")
                }
            } else {
                // If not authenticated, show login/sign-up options
                AuthTabsView()
            }
        }
    }
}

/// View that provides tab-based navigation between login and sign-up screens
struct AuthTabsView: View {
    var body: some View {
        TabView {
            // Login tab
            LoginView()
                .tabItem { Label("Login", systemImage: "rectangle.and.pencil.and.ellipsis") }

            // Sign-up tab
            SignUpView()
                .tabItem { Label("Sign Up", systemImage: "person.badge.plus") }
        }
    }
}
