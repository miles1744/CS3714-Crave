//
//  AddRecipeView.swift
//  CS3714-Crave
//

import SwiftUI
import SwiftData

struct AddRecipeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var auth: AuthViewModel

    @State private var title: String = ""
    @State private var shortDescription: String = ""
    @State private var ingredients: String = ""
    @State private var instructions: String = ""

    @State private var showSaved = false

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !ingredients.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !instructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            Section("Basics") {
                TextField("Recipe title", text: $title)

                TextField("Short description (optional)", text: $shortDescription, axis: .vertical)
                    .lineLimit(1...3)
            }

            Section("Ingredients") {
                TextEditor(text: $ingredients)
                    .frame(minHeight: 100)
                Text("Tip: use one ingredient per line, or bullets.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Instructions") {
                TextEditor(text: $instructions)
                    .frame(minHeight: 150)
                Text("Explain how to make it, step by step.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section {
                Button {
                    saveRecipe()
                } label: {
                    Text("Save Recipe")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isFormValid)
            }
        }
        .navigationTitle("Add Recipe")
        .alert("Recipe saved!", isPresented: $showSaved) {
            Button("OK", role: .cancel) { }
        }
    }

    private func saveRecipe() {
        guard let profile = auth.currentProfile else { return }

        let chefName = profile.displayName ?? profile.email
        let chefEmail = profile.email

        let recipe = ChefRecipe(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            shortDescription: shortDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            ingredients: ingredients.trimmingCharacters(in: .whitespacesAndNewlines),
            instructions: instructions.trimmingCharacters(in: .whitespacesAndNewlines),
            createdByEmail: chefEmail,
            createdByName: chefName,
            createdAt: .now
        )

        modelContext.insert(recipe)

        // Clear form
        title = ""
        shortDescription = ""
        ingredients = ""
        instructions = ""
        showSaved = true
    }
}
