//
//  MyRecipesView.swift
//  CS3714-Crave
//

import SwiftUI
import SwiftData

/// View that displays the current chef user's own created recipes
struct MyRecipesView: View {
    @Environment(\.modelContext) private var modelContext    // SwiftData model context
    @EnvironmentObject var auth: AuthViewModel               // Access current user profile

    // Fetch all ChefRecipe entries; we’ll filter manually by creator email
    @Query(sort: \ChefRecipe.createdAt, order: .reverse)
    private var allChefRecipes: [ChefRecipe]

    var body: some View {
        // Get current user's email
        let myEmail = auth.currentProfile?.email ?? ""

        // Filter only recipes created by this user
        let myRecipes = allChefRecipes.filter { $0.createdByEmail == myEmail }

        return Group {
            // No profile loaded (shouldn't happen if Auth is working)
            if myEmail.isEmpty {
                Text("No profile loaded.")
                    .foregroundStyle(.secondary)
            }
            // No recipes created yet
            else if myRecipes.isEmpty {
                VStack(spacing: 8) {
                    Text("No Recipes Yet")
                        .font(.title.bold())
                    Text("Create a recipe in the Add Recipe tab, and it will appear here.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            // Display list of user's recipes
            else {
                List {
                    ForEach(myRecipes) { recipe in
                        NavigationLink {
                            ChefRecipeDetailView(recipe: recipe)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(recipe.title)
                                    .font(.headline)

                                // Show short description or fallback to creator name
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
                        // Swipe-to-delete action
                        .swipeActions {
                            Button(role: .destructive) {
                                delete(recipe)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("My Recipes")
    }

    /// Deletes a recipe from SwiftData
    private func delete(_ recipe: ChefRecipe) {
        modelContext.delete(recipe)
    }
}
