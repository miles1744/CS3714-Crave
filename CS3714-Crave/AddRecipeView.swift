//
//  AddRecipeView.swift
//  CS3714-Crave
//

import SwiftUI
import SwiftData

/// View for adding a new recipe
struct AddRecipeView: View {
    // Access to the SwiftData model context
    @Environment(\.modelContext) private var modelContext
    
    // Access to the current authenticated user
    @EnvironmentObject var auth: AuthViewModel

    // Form input state variables
    @State private var title: String = ""
    @State private var shortDescription: String = ""
    @State private var ingredients: String = ""
    @State private var instructions: String = ""

    // Controls whether the success alert is shown
    @State private var showSaved = false

    // Computed property to validate the form before saving
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !ingredients.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !instructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            // Section for the recipe title and optional description
            Section("Basics") {
                TextField("Recipe title", text: $title)

                TextField("Short description (optional)", text: $shortDescription, axis: .vertical)
                    .lineLimit(1...3)
            }

            // Section for listing ingredients
            Section("Ingredients") {
                TextEditor(text: $ingredients)
                    .frame(minHeight: 100)
                Text("Tip: use one ingredient per line, or bullets.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            // Section for the step-by-step instructions
            Section("Instructions") {
                TextEditor(text: $instructions)
                    .frame(minHeight: 150)
                Text("Explain how to make it, step by step.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            // Submit button section
            Section {
                Button {
                    saveRecipe()
                } label: {
                    Text("Save Recipe")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isFormValid) // Disable button if form is incomplete
            }
        }
        .navigationTitle("Add Recipe")
        .alert("Recipe saved!", isPresented: $showSaved) {
            Button("OK", role: .cancel) { }
        }
    }

    /// Saves the recipe to the database and resets the form
    private func saveRecipe() {
        // Ensure we have a logged-in profile
        guard let profile = auth.currentProfile else { return }

        // Use displayName if available, else fallback to email
        let chefName = profile.displayName ?? profile.email
        let chefEmail = profile.email

        // Create a new ChefRecipe object with trimmed inputs
        let recipe = ChefRecipe(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            shortDescription: shortDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            ingredients: ingredients.trimmingCharacters(in: .whitespacesAndNewlines),
            instructions: instructions.trimmingCharacters(in: .whitespacesAndNewlines),
            createdByEmail: chefEmail,
            createdByName: chefName,
            createdAt: .now
        )

        // Insert into the SwiftData context
        modelContext.insert(recipe)

        // Reset form fields and show success alert
        title = ""
        shortDescription = ""
        ingredients = ""
        instructions = ""
        showSaved = true
    }
}
