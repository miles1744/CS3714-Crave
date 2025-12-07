//
//  RecipeDetailView.swift
//  CS3714-Crave
//
//  Created by Miles Thomas on 11/30/25.
//

import SwiftUI

/// View to display details of a Spoonacular recipe, including AI summary generation
struct RecipeDetailView: View {
    let recipe: Recipe  // The recipe to display

    @State private var aiSummary: String?       // AI-generated summary text
    @State private var isSummarizing = false    // Whether AI is generating a summary

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // ----------------------------
                // IMAGE SECTION
                // ----------------------------
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

                // ----------------------------
                // TITLE & METADATA
                // ----------------------------
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

                // ----------------------------
                // INSTRUCTIONS TEXT FALLBACK
                // ----------------------------
                // Use instructions if available, fallback to summary, or nil
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

                // ----------------------------
                // HOW TO MAKE IT SECTION
                // ----------------------------
                Text("How to Make It")
                    .font(.headline)

                if let baseText = instructionsText {
                    // Show raw instructions/summary
                    Text(baseText)
                        .font(.body)

                    // ----------------------------
                    // AI SUMMARY SECTION
                    // ----------------------------
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

                        // Display AI summary result
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
                    // No instructions or summary available
                    Text("Instructions are not available for this recipe.")
                        .foregroundStyle(.secondary)
                }

                // ----------------------------
                // EXTERNAL RECIPE LINK
                // ----------------------------
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

    // --------------------------------------------------
    // MARK: - HTML Stripping Utility for Instructions
    // --------------------------------------------------

    /// Removes basic HTML tags and entities from a Spoonacular recipe string
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

    // --------------------------------------------------
    // MARK: - Gemini AI Summary Generator
    // --------------------------------------------------

    /// Sends the recipe text to Gemini for a condensed bullet-point summary
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
