//
//  MyRecipesView.swift
//  CS3714-Crave
//

import SwiftUI
import SwiftData

struct MyRecipesView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var auth: AuthViewModel

    // We’ll manually filter by current chef email in body,
    // since @Query predicate capturing can be a bit strict.
    @Query(sort: \ChefRecipe.createdAt, order: .reverse)
    private var allChefRecipes: [ChefRecipe]

    var body: some View {
        let myEmail = auth.currentProfile?.email ?? ""
        let myRecipes = allChefRecipes.filter { $0.createdByEmail == myEmail }

        return Group {
            if myEmail.isEmpty {
                Text("No profile loaded.")
                    .foregroundStyle(.secondary)
            } else if myRecipes.isEmpty {
                VStack(spacing: 8) {
                    Text("No Recipes Yet")
                        .font(.title.bold())
                    Text("Create a recipe in the Add Recipe tab, and it will appear here.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            } else {
                List {
                    ForEach(myRecipes) { recipe in
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

    private func delete(_ recipe: ChefRecipe) {
        modelContext.delete(recipe)
    }
}
