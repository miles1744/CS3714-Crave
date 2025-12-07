//
//  SavedRecipe.swift
//  CS3714-Crave
//

import Foundation
import SwiftData

/// SwiftData model for a recipe that a user has saved (bookmarked)
@Model
class SavedRecipe {
    @Attribute(.unique) var id: Int             // Unique recipe ID (same as Spoonacular)
    var title: String                           // Recipe title
    var imageURL: String?                       // Optional image URL
    var readyInMinutes: Int?                    // Optional prep time
    var servings: Int?                          // Optional servings count

    // Additional fields to allow saved recipes to support full detail view
    var summary: String?                        // Optional HTML summary
    var instructions: String?                   // Optional HTML instructions
    var sourceUrl: String?                      // Optional link to original source

    var savedByEmail: String                    // Email of the user who saved the recipe

    /// Designated initializer for saved recipe
    init(
        id: Int,
        title: String,
        imageURL: String? = nil,
        readyInMinutes: Int? = nil,
        servings: Int? = nil,
        summary: String? = nil,
        instructions: String? = nil,
        sourceUrl: String? = nil,
        savedByEmail: String
    ) {
        self.id = id
        self.title = title
        self.imageURL = imageURL
        self.readyInMinutes = readyInMinutes
        self.servings = servings
        self.summary = summary
        self.instructions = instructions
        self.sourceUrl = sourceUrl
        self.savedByEmail = savedByEmail
    }

    /// Convenience initializer to convert a `Recipe` into a `SavedRecipe`
    convenience init(from recipe: Recipe, savedByEmail: String) {
        self.init(
            id: recipe.id,
            title: recipe.title,
            imageURL: recipe.image,
            readyInMinutes: recipe.readyInMinutes,
            servings: recipe.servings,
            summary: recipe.summary,
            instructions: recipe.instructions,
            sourceUrl: recipe.sourceUrl,
            savedByEmail: savedByEmail
        )
    }
}
