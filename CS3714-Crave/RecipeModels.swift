//
//  RecipeModels.swift
//  CS3714-Crave
//

import Foundation

/// Response model for Spoonacular API search
struct RecipeSearchResponse: Decodable {
    let results: [Recipe]   // Array of Recipe objects returned from the API
}

/// Represents a single recipe from Spoonacular or saved storage
struct Recipe: Identifiable, Decodable {
    let id: Int                     // Unique recipe ID
    let title: String               // Recipe title
    let image: String?              // Optional image URL
    let readyInMinutes: Int?        // Estimated prep time
    let servings: Int?              // Number of servings

    let summary: String?            // Optional short HTML summary
    let instructions: String?       // Optional full HTML instructions
    let sourceUrl: String?          // Original URL for full recipe
}

/// Extension to allow easy conversion from a SavedRecipe (local model)
extension Recipe {
    init(from saved: SavedRecipe) {
        self.init(
            id: saved.id,
            title: saved.title,
            image: saved.imageURL,
            readyInMinutes: saved.readyInMinutes,
            servings: saved.servings,
            summary: saved.summary,
            instructions: saved.instructions,
            sourceUrl: saved.sourceUrl
        )
    }
}
