//
//  SpoonacularAPI.swift
//  CS3714-Crave
//

import Foundation

enum SpoonacularError: Error, LocalizedError {
    case invalidURL
    case missingAPIKey
    case badResponse(status: Int, message: String?)
    case decodingError

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

struct SpoonacularAPI {
    static let shared = SpoonacularAPI()
    private init() {}

    // Uses Secrets.env → SPOONACULAR_API_KEY=...
    private var apiKey: String? {
        Secrets.shared.spoonacularAPIKey
    }

    func fetchRecipes(query: String?) async throws -> [Recipe] {
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            throw SpoonacularError.missingAPIKey
        }

        var components = URLComponents(string: "https://api.spoonacular.com/recipes/complexSearch")!

        var items: [URLQueryItem] = [
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "addRecipeInformation", value: "true"),
            URLQueryItem(name: "number", value: "20")
        ]

        // Free-text query from CraveView
        if let q = query, !q.trimmingCharacters(in: .whitespaces).isEmpty {
            items.append(URLQueryItem(name: "query", value: q))
        }

        // 🔥 Apply user food preferences from UserDefaults (set in FoodPreferencesView)
        let defaults = UserDefaults.standard

        // Diet (e.g. vegetarian, vegan, gluten free)
        if let diet = defaults.string(forKey: "dietPref"),
           !diet.isEmpty,
           diet != "None" {
            items.append(
                URLQueryItem(
                    name: "diet",
                    value: diet.lowercased()   // Spoonacular expects lowercase
                )
            )
        }

        // Intolerances (comma-separated string, e.g. "Dairy,Gluten")
        if let intolerances = defaults.string(forKey: "intolerancesPref"),
           !intolerances.trimmingCharacters(in: .whitespaces).isEmpty {
            items.append(
                URLQueryItem(
                    name: "intolerances",
                    value: intolerances
                )
            )
        }

        // Excluded ingredients (comma-separated, e.g. "tuna, mushrooms")
        if let exclude = defaults.string(forKey: "excludeIngredientsPref"),
           !exclude.trimmingCharacters(in: .whitespaces).isEmpty {
            items.append(
                URLQueryItem(
                    name: "excludeIngredients",
                    value: exclude
                )
            )
        }

        components.queryItems = items

        guard let url = components.url else {
            throw SpoonacularError.invalidURL
        }

        print("🌐 Spoonacular request:", url.absoluteString)

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse else {
            throw SpoonacularError.badResponse(status: -1, message: "No HTTP response")
        }

        guard 200..<300 ~= http.statusCode else {
            let body = String(data: data, encoding: .utf8)
            print("❌ Spoonacular HTTP \(http.statusCode):", body ?? "no body")
            throw SpoonacularError.badResponse(status: http.statusCode, message: body)
        }

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
