//
//  ChefRecipeDetailView.swift
//  CS3714-Crave
//

import SwiftUI

struct ChefRecipeDetailView: View {
    let recipe: ChefRecipe

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(recipe.title)
                    .font(.title.bold())

                Text("By \(recipe.createdByName)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Divider()

                if !recipe.shortDescription.isEmpty {
                    Text(recipe.shortDescription)
                        .font(.body)
                }

                Divider()

                Text("Ingredients")
                    .font(.headline)
                Text(recipe.ingredients)
                    .font(.body)

                Divider()

                Text("Instructions")
                    .font(.headline)
                Text(recipe.instructions)
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("Chef Recipe")
        .navigationBarTitleDisplayMode(.inline)
    }
}
