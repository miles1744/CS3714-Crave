//
//  ChefRecipeDetailView.swift
//  CS3714-Crave
//

import SwiftUI

/// Displays the full details of a single ChefRecipe
struct ChefRecipeDetailView: View {
    // The recipe to display, passed in from the list or selection view
    let recipe: ChefRecipe

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Recipe title
                Text(recipe.title)
                    .font(.title.bold())

                // Creator info
                Text("By \(recipe.createdByName)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Divider()

                // Optional short description (if present)
                if !recipe.shortDescription.isEmpty {
                    Text(recipe.shortDescription)
                        .font(.body)
                }

                Divider()

                // Ingredients section
                Text("Ingredients")
                    .font(.headline)
                Text(recipe.ingredients)
                    .font(.body)

                Divider()

                // Instructions section
                Text("Instructions")
                    .font(.headline)
                Text(recipe.instructions)
                    .font(.body)
            }
            .padding()
        }
        // Set navigation title for this detail screen
        .navigationTitle("Chef Recipe")
        .navigationBarTitleDisplayMode(.inline)
    }
}
