//
//  RecipeViewModel.swift
//  CS3714-Crave
//

import Foundation

/// ViewModel responsible for managing Spoonacular recipe search state and logic
@MainActor
class RecipeViewModel: ObservableObject {
    // The user's current search query
    @Published var query: String = ""

    // Recipes returned from the API based on the query
    @Published var recipes: [Recipe] = []

    // Loading state to show spinners during fetch
    @Published var isLoading: Bool = false

    // Any error message from the fetch process
    @Published var errorMessage: String?

    /// Performs an async search using SpoonacularAPI and updates published properties
    func search() async {
        isLoading = true          // Start spinner
        errorMessage = nil        // Clear previous error

        do {
            // Fetch results using the shared API wrapper
            let results = try await SpoonacularAPI.shared.fetchRecipes(query: query)
            self.recipes = results
        } catch {
            // If there's an error, extract readable message
            if let err = error as? LocalizedError {
                self.errorMessage = err.errorDescription
            } else {
                self.errorMessage = error.localizedDescription
            }
            print("❌ Error fetching recipes:", error)
        }

        isLoading = false         // Stop spinner
    }
}
