//
//  CraveView.swift
//  CS3714-Crave
//

import SwiftUI
import SwiftData

/// Main discovery view of the app — supports AI search, Spoonacular search, and saved chef recipes.
struct CraveView: View {
    
    @StateObject private var vm = RecipeViewModel() // Spoonacular search logic
    @Environment(\.modelContext) private var modelContext // SwiftData context
    @EnvironmentObject var auth: AuthViewModel      // Firebase auth + current user

    // All chef-created recipes, sorted from newest to oldest
    @Query(sort: \ChefRecipe.createdAt, order: .reverse)
    private var chefRecipes: [ChefRecipe]

    @State private var aiPrompt: String = ""     // Input prompt for AI recipe generation
    @State private var aiResult: String?         // AI response text

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
                            // Search bar for Spoonacular
                            TextField("e.g. pasta, burgers, vegan...", text: $vm.query)
                                .textFieldStyle(.roundedBorder)
                                .submitLabel(.search)
                                .onSubmit {
                                    Task { await vm.search() } // Trigger search
                                }

                            // Manual Go button
                            Button("Go") {
                                Task { await vm.search() }
                            }
                            .buttonStyle(.borderedProminent)
                        }

                        // Show loading state
                        if vm.isLoading {
                            ProgressView("Finding recipes...")
                                .padding(.top, 4)
                        }

                        // Show error message if API call fails
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

                        // AI prompt input field
                        TextField("Ask AI… e.g. 'healthy chicken dinner'", text: $aiPrompt)
                            .textFieldStyle(.roundedBorder)

                        // Button to trigger AI recipe generation
                        Button("Generate with AI") {
                            Task {
                                aiResult = await generateAIRecipe(from: aiPrompt)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(aiPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                        // Display AI result
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
                            // Empty state before search
                            Text("Search for something above to see recipes.")
                                .foregroundStyle(.secondary)
                        } else {
                            // List of recipes from Spoonacular API
                            ForEach(vm.recipes) { recipe in
                                HStack(spacing: 12) {
                                    // Thumbnail image
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

                                    // Title + metadata
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

                                    // Bookmark button to save the recipe locally
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
                            // Empty state for chef recipes
                            Text("No chef recipes available yet.")
                                .foregroundStyle(.secondary)
                        } else {
                            // List of recipes created by local chefs
                            ForEach(chefRecipes) { recipe in
                                HStack(alignment: .center, spacing: 12) {
                                    // Navigate to full recipe detail
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

                                    // Bookmark toggle
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
                // Perform an initial search on first load
                if vm.recipes.isEmpty {
                    vm.query = "pasta"
                    await vm.search()
                }
            }
        }
    }

    // MARK: - Save Spoonacular Recipe

    /// Saves a Spoonacular recipe to local storage if not already saved
    private func save(_ recipe: Recipe) {
        guard let userEmail = auth.currentProfile?.email else { return }
        let recipeID = recipe.id

        // Check if the recipe is already saved for this user
        let descriptor = FetchDescriptor<SavedRecipe>(
            predicate: #Predicate { saved in
                saved.id == recipeID && saved.savedByEmail == userEmail
            }
        )

        // Skip saving if already exists
        if let existing = try? modelContext.fetch(descriptor),
           !existing.isEmpty {
            return
        }

        // Create and save a new SavedRecipe object
        let saved = SavedRecipe(from: recipe, savedByEmail: userEmail)
        modelContext.insert(saved)
    }

    // MARK: - AI logic

    /// Uses Gemini API to generate a recipe from a free-text prompt
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
