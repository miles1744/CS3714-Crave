import Foundation
import SwiftData

@Model
class ChefRecipe {
    var title: String
    var shortDescription: String
    var ingredients: String
    var instructions: String

    var createdByEmail: String
    var createdByName: String
    var createdAt: Date

    // 👇 NEW: whether a general user has saved/bookmarked this recipe
    var isSaved: Bool

    init(
        title: String,
        shortDescription: String,
        ingredients: String,
        instructions: String,
        createdByEmail: String,
        createdByName: String,
        createdAt: Date = .now,
        isSaved: Bool = false          // default not saved
    ) {
        self.title = title
        self.shortDescription = shortDescription
        self.ingredients = ingredients
        self.instructions = instructions
        self.createdByEmail = createdByEmail
        self.createdByName = createdByName
        self.createdAt = createdAt
        self.isSaved = isSaved
    }
}
