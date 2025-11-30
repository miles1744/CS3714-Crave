//
//  CraveView.swift
//  CS3714-Crave
//

import SwiftUI

struct CraveView: View {
    @StateObject private var vm = RecipeViewModel()

    @State private var aiPrompt: String = ""
    @State private var aiResult: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: - Spoonacular Search
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Search Recipes")
                            .font(.title2.bold())

                        HStack {
                            TextField("e.g. pasta, burgers, vegan...", text: $vm.query)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .submitLabel(.search)
                                .onSubmit {
                                    Task { await vm.search() }
                                }

                            Button("Go") {
                                Task { await vm.search() }
                            }
                            .buttonStyle(.borderedProminent)
                        }

                        if vm.isLoading {
                            ProgressView("Finding recipes...")
                                .padding(.top, 4)
                        }

                        if let error = vm.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.callout)
                        }
                    }

                    Divider()

                    // MARK: - AI Recipe Lookup (space for Gemini/OpenAI)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("AI Recipe Lookup")
                            .font(.title2.bold())

                        Text("Ask AI to generate a recipe, meal idea, or ingredients list.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextField("Ask AI… e.g. “healthy chicken dinner”", text: $aiPrompt)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Button("Generate with AI") {
                            Task {
                                aiResult = nil
                                aiResult = await generateAIRecipe(from: aiPrompt)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(aiPrompt.trimmingCharacters(in: .whitespaces).isEmpty)

                        if let result = aiResult {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("AI Result")
                                    .font(.headline)

                                Text(result)
                                    .font(.body)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                        }
                    }

                    Divider()

                    // MARK: - Recipe Results
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Results")
                            .font(.title2.bold())

                        if vm.recipes.isEmpty {
                            Text("Search for something above to see recipes.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(vm.recipes) { recipe in
                                HStack(spacing: 12) {
                                    if let urlString = recipe.image,
                                       let url = URL(string: urlString) {
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(width: 70, height: 70)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(recipe.title)
                                            .font(.headline)

                                        HStack(spacing: 8) {
                                            if let minutes = recipe.readyInMinutes {
                                                Text("\(minutes) min")
                                            }
                                            if let servings = recipe.servings {
                                                Text("Serves \(servings)")
                                            }
                                        }
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }

                }
                .padding()
            }
            .navigationTitle("Crave")
            .task {
                // Optional: auto-load something on first open
                if vm.recipes.isEmpty {
                    vm.query = "pasta"
                    await vm.search()
                }
            }
        }
    }

    // MARK: - Placeholder AI function (replace with Gemini/OpenAI)
    func generateAIRecipe(from prompt: String) async -> String {
        guard !prompt.trimmingCharacters(in: .whitespaces).isEmpty else {
            return "Please enter a prompt for the AI."
        }

        // TODO: replace this with a real call:
        // try await GeminiAPI.shared.generateRecipe(prompt: "...")

        return """
        Here's a sample AI idea for: \(prompt)

        • Protein: Chicken breast
        • Base: Roasted vegetables
        • Sauce: Garlic herb yogurt
        • Extras: Fresh herbs + lemon

        Replace this text once your real AI integration is ready.
        """
    }
}
