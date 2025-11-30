//
//  CraveView.swift
//  CS3714-Crave
//

import SwiftUI
import SwiftData

struct CraveView: View {
    @StateObject private var vm = RecipeViewModel()
    @Environment(\.modelContext) private var modelContext

    // All chef recipes (for the "Chef Recipes" section)
    @Query(sort: \ChefRecipe.createdAt, order: .reverse)
    private var chefRecipes: [ChefRecipe]

    @State private var aiPrompt: String = ""
    @State private var aiResult: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // ---------------------------------------------------------
                    // MARK: - Spoonacular Search
                    // ---------------------------------------------------------
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Search Recipes")
                            .font(.title2.bold())

                        HStack {
                            TextField("e.g. pasta, burgers, vegan...", text: $vm.query)
                                .textFieldStyle(.roundedBorder)
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

                    // ---------------------------------------------------------
                    // MARK: - AI Recipe Lookup
                    // ---------------------------------------------------------
                    VStack(alignment: .leading, spacing: 12) {
                        Text("AI Recipe Lookup")
                            .font(.title2.bold())

                        TextField("Ask AI… e.g. 'healthy chicken dinner'", text: $aiPrompt)
                            .textFieldStyle(.roundedBorder)

                        Button("Generate with AI") {
                            Task {
                                aiResult = await generateAIRecipe(from: aiPrompt)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(aiPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                        if let result = aiResult {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("AI Result")
                                    .font(.headline)

                                Text(result)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                        }
                    }

                    Divider()

                    // ---------------------------------------------------------
                    // MARK: - Spoonacular Results
                    // ---------------------------------------------------------
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Results")
                            .font(.title2.bold())

                        if vm.recipes.isEmpty {
                            Text("Search for something above to see recipes.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(vm.recipes) { recipe in
                                HStack(spacing: 12) {
                                    if let urlStr = recipe.image,
                                       let url = URL(string: urlStr) {
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
                                            if let m = recipe.readyInMinutes {
                                                Text("\(m) min")
                                            }
                                            if let s = recipe.servings {
                                                Text("Serves \(s)")
                                            }
                                        }
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Button {
                                        save(recipe)
                                    } label: {
                                        Image(systemName: "bookmark.fill")
                                            .foregroundColor(.blue)
                                    }
                                    .buttonStyle(.borderless)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }

                    Divider()

                    // ---------------------------------------------------------
                    // MARK: - Chef Recipes
                    // ---------------------------------------------------------
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Chef Recipes")
                            .font(.title2.bold())

                        if chefRecipes.isEmpty {
                            Text("No chef recipes available yet.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(chefRecipes) { recipe in
                                HStack(alignment: .center, spacing: 12) {
                                    NavigationLink {
                                        ChefRecipeDetailView(recipe: recipe)
                                    } label: {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(recipe.title)
                                                .font(.headline)

                                            if !recipe.shortDescription.isEmpty {
                                                Text(recipe.shortDescription)
                                                    .font(.subheadline)
                                                    .foregroundStyle(.secondary)
                                            } else {
                                                Text("By \(recipe.createdByName)")
                                                    .font(.subheadline)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }

                                    Button {
                                        recipe.isSaved.toggle()
                                    } label: {
                                        Image(systemName: recipe.isSaved ? "bookmark.fill" : "bookmark")
                                    }
                                    .buttonStyle(.borderless)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                    }

                } // VStack
                .padding()
            } // ScrollView
            .navigationTitle("Crave")
            .task {
                if vm.recipes.isEmpty {
                    vm.query = "pasta"
                    await vm.search()
                }
            }
        }
    }

    // MARK: - Save Spoonacular Recipe
    private func save(_ recipe: Recipe) {
        let recipeID = recipe.id

        let descriptor = FetchDescriptor<SavedRecipe>(
            predicate: #Predicate { $0.id == recipeID }
        )

        if let existing = try? modelContext.fetch(descriptor),
           !existing.isEmpty {
            return   // already saved
        }

        let saved = SavedRecipe(from: recipe)
        modelContext.insert(saved)
    }

    // MARK: - AI logic
    func generateAIRecipe(from prompt: String) async -> String {
        let trimmed = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return "Please enter a prompt."
        }

        do {
            return try await GeminiAPI.shared.generateRecipe(
                prompt: "Generate a detailed recipe for: \(trimmed)"
            )
        } catch {
            return "AI error: \(error.localizedDescription)"
        }
    }
}
