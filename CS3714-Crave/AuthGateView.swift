//
//  AuthGateView.swift
//  CS3714-Crave
//
//  Created by Brendan Michael Riordan on 11/9/25.
//

import SwiftUI
import SwiftData

struct AuthGateView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Query(sort: \UserProfile.email) private var profiles: [UserProfile]

    var body: some View {
        Group {
            if auth.isAuthenticated {
                HomeView(profile: profiles.first)
            } else {
                AuthTabsView()
            }
        }
    }
}

struct AuthTabsView: View {
    var body: some View {
        TabView {
            LoginView()
                .tabItem { Label("Login", systemImage: "rectangle.and.pencil.and.ellipsis") }
            SignUpView()
                .tabItem { Label("Sign Up", systemImage: "person.badge.plus") }
        }
    }
}
