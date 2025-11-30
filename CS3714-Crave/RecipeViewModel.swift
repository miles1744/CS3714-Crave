//
//  RecipeViewModel.swift
//  CS3714-Crave
//

import Foundation

@MainActor
class RecipeViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var recipes: [Recipe] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    func search() async {
        isLoading = true
        errorMessage = nil

        do {
            let results = try await SpoonacularAPI.shared.fetchRecipes(query: query)
            self.recipes = results
        } catch {
            if let err = error as? LocalizedError {
                self.errorMessage = err.errorDescription
            } else {
                self.errorMessage = error.localizedDescription
            }
            print("❌ Error fetching recipes:", error)
        }

        isLoading = false
    }
}
