
//
//  Secrets.swift
//  CS3714-Crave
//

import Foundation

struct Secrets {
    static let shared = Secrets()

    private let values: [String: String]

    private init() {
        // Load Secrets.env from app bundle
        if let url = Bundle.main.url(forResource: "Secrets", withExtension: "env"),
           let contents = try? String(contentsOf: url, encoding: .utf8) {

            var dict: [String: String] = [:]

            // Parse KEY=VALUE pairs
            for line in contents.split(whereSeparator: \.isNewline) {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }

                let parts = trimmed.split(separator: "=", maxSplits: 1)
                if parts.count == 2 {
                    let key = parts[0].trimmingCharacters(in: .whitespaces)
                    let value = parts[1].trimmingCharacters(in: .whitespaces)
                    dict[key] = value
                }
            }

            self.values = dict
        } else {
            print("⚠️ Warning: Secrets.env not found in bundle.")
            self.values = [:]
        }
    }

    func value(for key: String) -> String? {
        values[key]
    }

    // Spoonacular
    var spoonacularAPIKey: String? {
        value(for: "SPOONACULAR_API_KEY")
    }

    // Gemini API
    var geminiAPIKey: String? {
        value(for: "GEMINI_API_KEY")
    }
}
