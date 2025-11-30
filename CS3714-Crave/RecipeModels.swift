//
//  RecipeModels.swift
//  CS3714-Crave
//

import Foundation

struct RecipeSearchResponse: Codable {
    let results: [Recipe]
}

struct Recipe: Codable, Identifiable {
    let id: Int
    let title: String
    let image: String?

    let readyInMinutes: Int?
    let servings: Int?
    let summary: String?    // HTML string from Spoonacular
}
