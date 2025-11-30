//
//  RecipeDetailView.swift
//  CS3714-Crave
//
//  Created by Miles Thomas on 11/30/25.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe

    @State private var aiSummary: String?
    @State private var isSummarizing = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Image
                if let img = recipe.image,
                   let url = URL(string: img) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 220)
                    .clipped()
                    .cornerRadius(16)
                }

                // Title + meta
                Text(recipe.title)
                    .font(.title.bold())

                HStack(spacing: 12) {
                    if let minutes = recipe.readyInMinutes {
                        Label("\(minutes) min", systemImage: "clock")
                    }
                    if let servings = recipe.servings {
                        Label("Serves \(servings)", systemImage: "person.2")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Divider()

                // Decide what base text we have (instructions or summary)
                let instructionsText: String? = {
                    if let instructions = recipe.instructions,
                       !instructions.isEmpty {
                        return stripHTML(instructions)
                    } else if let summary = recipe.summary {
                        return stripHTML(summary)
                    } else {
                        return nil
                    }
                }()

                // HOW TO MAKE IT
                Text("How to Make It")
                    .font(.headline)

                if let baseText = instructionsText {
                    Text(baseText)
                        .font(.body)

                    // MARK: - AI Summary
                    VStack(alignment: .leading, spacing: 8) {
                        Button {
                            Task {
                                isSummarizing = true
                                aiSummary = nil
                                aiSummary = await summarizeWithAI(from: baseText)
                                isSummarizing = false
                            }
                        } label: {
                            HStack {
                                if isSummarizing {
                                    ProgressView()
                                        .tint(.white)
                                }
                                Text(isSummarizing ? "Summarizing..." : "Summarize with AI")
                            }
                        }
                        .buttonStyle(.borderedProminent)

                        if let summary = aiSummary {
                            Text("AI Summary")
                                .font(.headline)
                                .padding(.top, 4)

                            Text(summary)
                                .font(.body)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.top, 8)

                } else {
                    Text("Instructions are not available for this recipe.")
                        .foregroundStyle(.secondary)
                }

                // Optional: link to original
                if let urlString = recipe.sourceUrl,
                   let url = URL(string: urlString) {
                    Divider()
                    Link("Open full recipe on the web", destination: url)
                        .font(.body.weight(.semibold))
                }
            }
            .padding()
        }
        .navigationTitle("Recipe")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Quick & dirty HTML stripper for Spoonacular text
    private func stripHTML(_ html: String) -> String {
        html
            .replacingOccurrences(of: "<br>", with: "\n")
            .replacingOccurrences(of: "<br />", with: "\n")
            .replacingOccurrences(of: "<li>", with: "• ")
            .replacingOccurrences(of: "</li>", with: "\n")
            .replacingOccurrences(of: "<[^>]+>", with: "",
                                  options: .regularExpression)
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
    }

    // Use Gemini to create a condensed summary
    private func summarizeWithAI(from text: String) async -> String {
        do {
            let prompt = """
            Summarize these recipe instructions into 5 short bullet points \
            (under 80 words total). Use plain text bullets:

            \(text)
            """
            return try await GeminiAPI.shared.generateRecipe(prompt: prompt)
        } catch {
            return "AI error: \(error.localizedDescription)"
        }
    }
}
