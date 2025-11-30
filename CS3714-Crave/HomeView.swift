//
//  HomeView.swift
//  CS3714-Crave
//
//  Created by Brendan Michael Riordan on 11/9/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var auth: AuthViewModel

    @State private var newName: String = ""
    @State private var selectedTab: Tab = .home

    enum Tab {
        case home
        case crave
        case saved
        case preferences
        case addRecipe
        case myRecipes
    }

    // Always use the *current* logged-in profile from AuthViewModel
    private var profile: UserProfile? {
        auth.currentProfile
    }

    // Chef vs general user (default to "General User" if no usertype yet)
    private var isChef: Bool {
        (profile?.userType ?? "General User") == "Chef"
    }

    var body: some View {
        VStack(spacing: 12) {

            // HEADER BAR
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    headerButton("Home", tab: .home)
                    headerButton("Crave", tab: .crave)

                    if isChef {
                        // Chef-only tabs
                        headerButton("Add Recipe", tab: .addRecipe)
                        headerButton("My Recipes", tab: .myRecipes)
                    } else {
                        // General user tabs
                        headerButton("Saved Recipes", tab: .saved)
                        headerButton("Preferences", tab: .preferences)
                    }
                }
                .padding(.vertical, 8)
            }

            Divider()

            // MAIN CONTENT AREA – changes by selectedTab
            switch selectedTab {
            case .home:
                homeContent

            case .crave:
                // 🔥 This is where your Spoonacular + AI CraveView lives
                CraveView()
                    .frame(maxWidth: .infinity,
                           maxHeight: .infinity,
                           alignment: .topLeading)

            case .saved:
                VStack(spacing: 8) {
                    Text("Saved Recipes")
                        .font(.title.bold())
                    Text("Your bookmarked recipes will appear here.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            case .preferences:
                VStack(spacing: 8) {
                    Text("Preferences")
                        .font(.title.bold())
                    Text("Customize your experience: email type, dietary preferences, and more.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            case .addRecipe:
                VStack(spacing: 8) {
                    Text("Add Recipe")
                        .font(.title.bold())
                    Text("As a chef, you can create new recipes to share with users here.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            case .myRecipes:
                VStack(spacing: 8) {
                    Text("My Recipes")
                        .font(.title.bold())
                    Text("Manage and edit all the recipes you’ve created.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - Subviews

    private func headerButton(_ title: String, tab: Tab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    selectedTab == tab
                    ? Color.accentColor.opacity(0.15)
                    : Color.clear
                )
                .clipShape(Capsule())
        }
    }

    private var homeContent: some View {
        VStack(spacing: 12) {
            if let p = profile {
                if isChef {
                    // 👨‍🍳 CHEF HOME
                    Text("Welcome, Chef \(p.displayName ?? p.email)")
                        .font(.title.bold())
                        .multilineTextAlignment(.center)

                    Text("Use Crave to share your recipes with hungry users.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    // Quick actions for chefs
                    HStack {
                        Button {
                            selectedTab = .addRecipe
                        } label: {
                            Text("Add Recipe")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            selectedTab = .myRecipes
                        } label: {
                            Text("My Recipes")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.top, 8)

                } else {
                    // 👤 GENERAL USER HOME
                    Text("Signed In")
                        .font(.title.bold())

                    Text(p.displayName ?? p.email)
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    HStack {
                        TextField("Update display name", text: $newName)
                            .textFieldStyle(.roundedBorder)
                        Button("Save") {
                            Task { await auth.updateDisplayName(newName) }
                            newName = ""
                        }
                        .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.top, 8)
                }
            } else {
                Text("No local profile found yet.")
                    .foregroundStyle(.secondary)
            }

            Button("Sign Out") {
                auth.signOut()
            }
            .buttonStyle(.bordered)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
}
