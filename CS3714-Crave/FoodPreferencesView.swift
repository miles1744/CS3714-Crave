//
//  FoodPreferencesView.swift
//  CS3714-Crave
//

import SwiftUI

/// View for users to set dietary preferences, ingredient exclusions, and intolerances.
struct FoodPreferencesView: View {
    // Persisted values using @AppStorage (backed by UserDefaults)
    @AppStorage("dietPref") private var dietPref: String = "None"
    @AppStorage("excludeIngredientsPref") private var excludePref: String = ""
    @AppStorage("intolerancesPref") private var intolerancesPref: String = ""

    // Local UI state variables (synced on appear)
    @State private var selectedDiet: String = "None"
    @State private var excludeIngredients: String = ""
    @State private var selectedIntolerances: Set<String> = []

    // Available diet options for Picker
    private let diets = [
        "None",
        "Vegetarian",
        "Vegan",
        "Pescetarian",
        "Gluten Free",
        "Ketogenic"
    ]

    // Common food intolerance options (rendered as toggles)
    private let intoleranceOptions = [
        "Dairy", "Egg", "Gluten", "Peanut", "Seafood",
        "Sesame", "Shellfish", "Soy", "Sulfite",
        "Tree Nut", "Wheat"
    ]

    var body: some View {
        Form {
            // --------------------
            // Diet preference
            // --------------------
            Section("Diet") {
                Picker("Diet", selection: $selectedDiet) {
                    ForEach(diets, id: \.self) { diet in
                        Text(diet).tag(diet)
                    }
                }
            }

            // --------------------
            // Intolerances section
            // --------------------
            Section("Intolerances") {
                ForEach(intoleranceOptions, id: \.self) { option in
                    Toggle(isOn: bindingForIntolerance(option)) {
                        Text(option)
                    }
                }
            }

            // --------------------
            // Ingredient exclusions
            // --------------------
            Section("Exclude Ingredients") {
                TextField("e.g. tuna, mushrooms", text: $excludeIngredients)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                Text("Separate with commas. These ingredients will be avoided in search results.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Preferences")

        // Load saved preferences when view appears
        .onAppear {
            selectedDiet = dietPref
            excludeIngredients = excludePref

            // Parse intolerances CSV string into a set
            let parts = intolerancesPref
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }

            selectedIntolerances = Set(parts)
        }

        // Update stored diet preference when changed
        .onChange(of: selectedDiet) { oldValue, newValue in
            dietPref = newValue
        }

        // Update stored ingredient exclusions when changed
        .onChange(of: excludeIngredients) { oldValue, newValue in
            excludePref = newValue
        }
    }

    // MARK: - Helpers

    /// Provides a toggle binding for a given intolerance option
    private func bindingForIntolerance(_ option: String) -> Binding<Bool> {
        Binding(
            get: { selectedIntolerances.contains(option) },
            set: { isOn in
                if isOn {
                    selectedIntolerances.insert(option)
                } else {
                    selectedIntolerances.remove(option)
                }
                saveIntolerances() // Update persistent storage
            }
        )
    }

    /// Saves current intolerances set to AppStorage as a CSV string
    private func saveIntolerances() {
        intolerancesPref = selectedIntolerances
            .sorted()
            .joined(separator: ",")
    }
}
