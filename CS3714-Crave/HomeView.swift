//
//  HomeView.swift
//  CS3714-Crave
//
//  Created by Brendan Michael Riordan on 11/9/25.
//

import SwiftUI
import SwiftData

/// Main entry point after login — renders different tabs based on user type (Chef or General User)
struct HomeView: View {
    @EnvironmentObject var auth: AuthViewModel           // Access current user info
    @Environment(\.modelContext) private var modelContext // SwiftData context for persistence

    // Query saved Spoonacular recipes and Chef-created recipes
    @Query(sort: \SavedRecipe.title) private var savedRecipes: [SavedRecipe]
    @Query(sort: \ChefRecipe.title) private var chefRecipes: [ChefRecipe]

    @State private var newName: String = ""              // For updating display name
    @State private var selectedTab: Tab = .home          // Current selected tab

    /// Available tabs in the view
    enum Tab {
        case home
        case crave
        case saved
        case preferences
        case addRecipe
        case myRecipes
    }

    /// Returns the current logged-in profile from auth
    private var profile: UserProfile? {
        auth.currentProfile
    }

    /// Determines if the user is a Chef
    private var isChef: Bool {
        (profile?.userType ?? "General User") == "Chef"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {

                // Top horizontal tab bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        headerButton("Home", tab: .home)

                        if isChef {
                            // Show Chef-only tabs
                            headerButton("Add Recipe", tab: .addRecipe)
                            headerButton("My Recipes", tab: .myRecipes)
                        } else {
                            // Show General User tabs
                            headerButton("Crave", tab: .crave)
                            headerButton("Saved Recipes", tab: .saved)
                            headerButton("Preferences", tab: .preferences)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Divider()

                // Show tab content based on current tab selection
                switch selectedTab {
                case .home:
                    homeContent
                    
                case .crave:
                    CraveView()
                        .environmentObject(auth)
                        .frame(maxWidth: .infinity,
                               maxHeight: .infinity,
                               alignment: .topLeading)
                    
                case .saved:
                    savedContent
                    
                case .preferences:
                    FoodPreferencesView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                case .addRecipe:
                    AddRecipeView()
                        .frame(maxWidth: .infinity,
                               maxHeight: .infinity,
                               alignment: .top)
                        .environmentObject(auth)   // pass down auth info
                    
                case .myRecipes:
                    MyRecipesView()
                        .frame(maxWidth: .infinity,
                               maxHeight: .infinity,
                               alignment: .top)
                        .environmentObject(auth)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Saved Recipes Content

    /// Displays both Spoonacular and Chef recipes that the user has saved/bookmarked
    private var savedContent: some View {
        let userEmail = auth.currentProfile?.email ?? ""
        
        // Filter saved Spoonacular recipes by logged-in user
        let userSavedRecipes = savedRecipes.filter { $0.savedByEmail == userEmail }
        
        // Filter chef recipes marked as saved
        let savedChefRecipes = chefRecipes.filter { $0.isSaved }

        return VStack(alignment: .leading, spacing: 16) {
            // --- Spoonacular Recipes ---
            Text("Saved Recipes")
                .font(.title.bold())

            if userSavedRecipes.isEmpty {
                Text("You haven't saved any Spoonacular recipes yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                List {
                    ForEach(userSavedRecipes) { saved in
                        NavigationLink {
                            RecipeDetailView(recipe: Recipe(from: saved))
                        } label: {
                            HStack(spacing: 12) {
                                if let urlString = saved.imageURL,
                                   let url = URL(string: urlString) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 70, height: 70)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(saved.title)
                                        .font(.headline)

                                    HStack(spacing: 8) {
                                        if let minutes = saved.readyInMinutes {
                                            Text("\(minutes) min")
                                        }
                                        if let servings = saved.servings {
                                            Text("Serves \(servings)")
                                        }
                                    }
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        // Swipe to delete saved recipe
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                removeSaved(saved)
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }

            // --- Chef Recipes ---
            Divider()

            Text("Saved Chef Recipes")
                .font(.title2.bold())

            if savedChefRecipes.isEmpty {
                Text("You haven't saved any chef recipes yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                List {
                    ForEach(savedChefRecipes) { recipe in
                        NavigationLink {
                            ChefRecipeDetailView(recipe: recipe)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(recipe.title)
                                    .font(.headline)
                                if !recipe.shortDescription.isEmpty {
                                    Text(recipe.shortDescription)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text("By \(recipe.createdByName)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        // Swipe to unsave the recipe (does not delete it)
                        .swipeActions {
                            Button(role: .destructive) {
                                recipe.isSaved = false
                            } label: {
                                Label("Unsave", systemImage: "bookmark.slash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Helpers

    /// Deletes a saved Spoonacular recipe from local storage
    private func removeSaved(_ recipe: SavedRecipe) {
        modelContext.delete(recipe)
        // Note: add try? modelContext.save() if using persistent storage
    }

    /// Reusable button for switching tabs in the horizontal header
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

    /// Content for the Home tab (varies based on user type)
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
                // No profile yet
                Text("No local profile found yet.")
                    .foregroundStyle(.secondary)
            }

            // Sign out button
            Button("Sign Out") {
                auth.signOut()
            }
            .buttonStyle(.bordered)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
}
