//
//  SpoonacularAPI.swift
//  CS3714-Crave
//

import Foundation

/// Custom error types for Spoonacular API failures
enum SpoonacularError: Error, LocalizedError {
    case invalidURL
    case missingAPIKey
    case badResponse(status: Int, message: String?)
    case decodingError

    /// Human‑readable error messages for UI display
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Spoonacular URL."
        case .missingAPIKey:
            return "Missing Spoonacular API key."
        case .badResponse(let status, let message):
            return "Bad response from Spoonacular (status \(status)): \(message ?? "Unknown error")."
        case .decodingError:
            return "Couldn't decode recipe data."
        }
    }
}

/// API client for fetching recipes from Spoonacular
struct SpoonacularAPI {
    static let shared = SpoonacularAPI()   // Singleton instance
    private init() {}

    // Retrieve API key from Secrets.swift
    private var apiKey: String? {
        Secrets.shared.spoonacularAPIKey
    }

    /// Fetches recipes from Spoonacular based on query + stored preferences
    func fetchRecipes(query: String?) async throws -> [Recipe] {
        // Ensure API key exists
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            throw SpoonacularError.missingAPIKey
        }

        // Base endpoint for the complex search
        var components = URLComponents(string: "https://api.spoonacular.com/recipes/complexSearch")!

        // Standard required query parameters
        var items: [URLQueryItem] = [
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "addRecipeInformation", value: "true"),
            URLQueryItem(name: "number", value: "20")
        ]

        // Add user-entered free-text search query
        if let q = query, !q.trimmingCharacters(in: .whitespaces).isEmpty {
            items.append(URLQueryItem(name: "query", value: q))
        }

        // 🔥 Apply user preferences saved via AppStorage (UserDefaults)
        let defaults = UserDefaults.standard

        // --- Diet preference ---
        if let diet = defaults.string(forKey: "dietPref"),
           !diet.isEmpty,
           diet != "None" {
            items.append(
                URLQueryItem(
                    name: "diet",
                    value: diet.lowercased() // Spoonacular requires lowercase formatting
                )
            )
        }

        // --- Intolerances preference (comma‑separated list) ---
        if let intolerances = defaults.string(forKey: "intolerancesPref"),
           !intolerances.trimmingCharacters(in: .whitespaces).isEmpty {
            items.append(URLQueryItem(name: "intolerances", value: intolerances))
        }

        // --- Excluded ingredients ---
        if let exclude = defaults.string(forKey: "excludeIngredientsPref"),
           !exclude.trimmingCharacters(in: .whitespaces).isEmpty {
            items.append(URLQueryItem(name: "excludeIngredients", value: exclude))
        }

        components.queryItems = items

        // Validate final URL
        guard let url = components.url else {
            throw SpoonacularError.invalidURL
        }

        print("🌐 Spoonacular request:", url.absoluteString)

        // Perform network request
        let (data, response) = try await URLSession.shared.data(from: url)

        // Validate HTTP response
        guard let http = response as? HTTPURLResponse else {
            throw SpoonacularError.badResponse(status: -1, message: "No HTTP response")
        }

        // Handle non‑success HTTP codes
        guard 200..<300 ~= http.statusCode else {
            let body = String(data: data, encoding: .utf8)
            print("❌ Spoonacular HTTP \(http.statusCode):", body ?? "no body")
            throw SpoonacularError.badResponse(status: http.statusCode, message: body)
        }

        // Decode Spoonacular results into model types
        do {
            let decoded = try JSONDecoder().decode(RecipeSearchResponse.self, from: data)
            print("✅ Spoonacular returned \(decoded.results.count) recipes")
            return decoded.results
        } catch {
            print("❌ Decoding error:", error)
            throw SpoonacularError.decodingError
        }
    }
}
