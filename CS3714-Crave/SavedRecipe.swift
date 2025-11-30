//
//  SavedRecipe.swift
//  CS3714-Crave
//

import Foundation
import SwiftData

@Model
class SavedRecipe {
    // Use Spoonacular ID as primary key
    @Attribute(.unique) var id: Int
    var title: String
    var imageURL: String?
    var readyInMinutes: Int?
    var servings: Int?

    init(id: Int,
         title: String,
         imageURL: String? = nil,
         readyInMinutes: Int? = nil,
         servings: Int? = nil) {
        self.id = id
        self.title = title
        self.imageURL = imageURL
        self.readyInMinutes = readyInMinutes
        self.servings = servings
    }

    convenience init(from recipe: Recipe) {
        self.init(
            id: recipe.id,
            title: recipe.title,
            imageURL: recipe.image,
            readyInMinutes: recipe.readyInMinutes,
            servings: recipe.servings
        )
    }
}
