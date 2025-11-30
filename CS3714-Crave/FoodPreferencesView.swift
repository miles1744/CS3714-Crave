//
//  FoodPreferencesView.swift
//  CS3714-Crave
//

import SwiftUI

struct FoodPreferencesView: View {
    // Persisted values (UserDefaults via AppStorage)
    @AppStorage("dietPref") private var dietPref: String = "None"
    @AppStorage("excludeIngredientsPref") private var excludePref: String = ""
    @AppStorage("intolerancesPref") private var intolerancesPref: String = ""

    // Local UI state
    @State private var selectedDiet: String = "None"
    @State private var excludeIngredients: String = ""
    @State private var selectedIntolerances: Set<String> = []

    private let diets = [
        "None",
        "Vegetarian",
        "Vegan",
        "Pescetarian",
        "Gluten Free",
        "Ketogenic"
    ]

    private let intoleranceOptions = [
        "Dairy", "Egg", "Gluten", "Peanut", "Seafood",
        "Sesame", "Shellfish", "Soy", "Sulfite",
        "Tree Nut", "Wheat"
    ]

    var body: some View {
        Form {
            Section("Diet") {
                Picker("Diet", selection: $selectedDiet) {
                    ForEach(diets, id: \.self) { diet in
                        Text(diet).tag(diet)
                    }
                }
            }

            Section("Intolerances") {
                ForEach(intoleranceOptions, id: \.self) { option in
                    Toggle(isOn: bindingForIntolerance(option)) {
                        Text(option)
                    }
                }
            }

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
        .onAppear {
            // Sync UI from stored values
            selectedDiet = dietPref
            excludeIngredients = excludePref

            let parts = intolerancesPref
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }

            selectedIntolerances = Set(parts)
        }
        
        .onChange(of: selectedDiet) { oldValue, newValue in
            dietPref = newValue
        }
        
        .onChange(of: excludeIngredients) { oldValue, newValue in
            excludePref = newValue
        }
    }

    // MARK: - Helpers

    private func bindingForIntolerance(_ option: String) -> Binding<Bool> {
        Binding(
            get: { selectedIntolerances.contains(option) },
            set: { isOn in
                if isOn {
                    selectedIntolerances.insert(option)
                } else {
                    selectedIntolerances.remove(option)
                }
                saveIntolerances()
            }
        )
    }

    private func saveIntolerances() {
        intolerancesPref = selectedIntolerances
            .sorted()
            .joined(separator: ",")
    }
}
