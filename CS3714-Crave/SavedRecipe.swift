//
//  SavedRecipe.swift
//  CS3714-Crave
//

import Foundation
import SwiftData

@Model
class SavedRecipe {
    @Attribute(.unique) var id: Int
    var title: String
    var imageURL: String?
    var readyInMinutes: Int?
    var servings: Int?

    // New fields so detail view works for saved recipes too
    var summary: String?
    var instructions: String?
    var sourceUrl: String?
    var savedByEmail: String

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
