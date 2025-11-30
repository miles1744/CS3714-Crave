//
//  RecipeModels.swift
//  CS3714-Crave
//

import Foundation

struct RecipeSearchResponse: Decodable {
    let results: [Recipe]
}

// One recipe
struct Recipe: Identifiable, Decodable {
    let id: Int
    let title: String
    let image: String?
    let readyInMinutes: Int?
    let servings: Int?

    let summary: String?        // short HTML summary
    let instructions: String?   // full HTML instructions
    let sourceUrl: String?      // original website
}


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
