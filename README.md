This is our Crave Application.

Our app allows users to effectively find recipes that fit all of their dietary restrictions and fit within the time limits of our busy schedules. 
This application uses the Spoonacular API which gives us access to a large database of existing recipes.
Crave allows users to either login as a user or as a chef and if they are a Chef they would be allowed to add new recipes which would be added to the list. 
The main feature that our application has is the AI feature that allows users to search and our appliction uses AI to find the best recipes for them based on their prompt.

Some of the known issues include not being able to unfavoirte recipes from the Crave tab but you can delete them by swiping right on the saved recipes tab.



To run the project you need to add the Secrets.swift, Secrets.env, and GoogleService-Info.
This is due to gitguardian privacy not allowing api keys to be public on github

**Secrets.swift**

//
//  Secrets.swift
//  CS3714-Crave
//
//  Loads API keys from a Secrets.env file bundled inside the app.
//  Allows storing sensitive environment values outside of source code.
//

import Foundation

/// Singleton responsible for loading key-value pairs from `Secrets.env`.
/// The file is expected to be included in the app bundle and contain items
/// formatted as:
///
///     KEY=value
///
/// Comments (#...) and blank lines are ignored.
struct Secrets {

    /// Global shared accessor.
    static let shared = Secrets()

    /// Internal dictionary of loaded secrets.
    private let values: [String: String]

    // ---------------------------------------------------------------------
    // MARK: - Init (Load Secrets.env)
    // ---------------------------------------------------------------------
    private init() {

        // Attempt to load "Secrets.env" from main bundle
        if let url = Bundle.main.url(forResource: "Secrets", withExtension: "env"),
           let contents = try? String(contentsOf: url, encoding: .utf8) {

            var dict: [String: String] = [:]

            // Parse each line into KEY=VALUE pairs
            for line in contents.split(whereSeparator: \.isNewline) {

                let trimmed = line.trimmingCharacters(in: .whitespaces)

                // Ignore empty lines and comments
                if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }

                // Split into key=value
                let parts = trimmed.split(separator: "=", maxSplits: 1)

                if parts.count == 2 {
                    let key = parts[0].trimmingCharacters(in: .whitespaces)
                    let value = parts[1].trimmingCharacters(in: .whitespaces)
                    dict[key] = value
                }
            }

            self.values = dict

        } else {
            // If file doesn't load, app will still run but keys will be nil
            print("⚠️ Warning: Secrets.env not found in bundle.")
            self.values = [:]
        }
    }

    // ---------------------------------------------------------------------
    // MARK: - Access Helpers
    // ---------------------------------------------------------------------

    /// Returns the secret value for a given key, or nil if not found.
    func value(for key: String) -> String? {
        values[key]
    }

    // ---------------------------------------------------------------------
    // MARK: - Public API Keys
    // ---------------------------------------------------------------------

    /// Spoonacular API key extracted from Secrets.env
    var spoonacularAPIKey: String? {
        value(for: "SPOONACULAR_API_KEY")
    }

    /// Gemini API key extracted from Secrets.env
    var geminiAPIKey: String? {
        value(for: "GEMINI_API_KEY")
    }
}

**Secrets.env**
SPOONACULAR_API_KEY=e3c0d09979ad476686ca082aadf6706c
GEMINI_API_KEY=AIzaSyAacTDaZ-lD1BVj1AASKwGQZjIv1YiV8DU





