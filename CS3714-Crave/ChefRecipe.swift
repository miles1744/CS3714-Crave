import Foundation
import SwiftData

/// Model representing a recipe created by a chef or user.
/// Stored using SwiftData and optionally synced with Firestore.
@Model
class ChefRecipe {
    // Recipe title (required)
    var title: String

    // Short, optional description of the recipe
    var shortDescription: String

    // Ingredients list as a plain string
    var ingredients: String

    // Step-by-step instructions for preparation
    var instructions: String

    // Email of the user who created the recipe (used for ownership)
    var createdByEmail: String

    // Display name of the creator (shown in UI)
    var createdByName: String

    // Timestamp of when the recipe was created
    var createdAt: Date

    //whether a general user has saved/bookmarked this recipe
    var isSaved: Bool

    /// Initializer for creating a new `ChefRecipe` instance
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
