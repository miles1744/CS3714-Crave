//
//  HomeView.swift
//  CS3714-Crave
//
//  Created by Brendan Michael Riordan on 11/9/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var auth: AuthViewModel
    var profile: UserProfile?

    @State private var newName: String = ""

    var body: some View {
        VStack(spacing: 12) {
            Text("Signed In").font(.title.bold())

            if let p = profile {
                Text(p.displayName ?? p.email)
                    .font(.headline).foregroundStyle(.secondary)

                // Optional: inline edit of display name (writes both to Firestore and SwiftData)
                HStack {
                    TextField("Update display name", text: $newName)
                        .textFieldStyle(.roundedBorder)
                    Button("Save") {
                        Task { await auth.updateDisplayName(newName) }
                        newName = ""
                    }
                    .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.top, 8)
            } else {
                Text("No local profile found yet.").foregroundStyle(.secondary)
            }

            Button("Sign Out") { auth.signOut() }
                .buttonStyle(.bordered)
                .padding(.top, 8)

            Spacer()
        }
        .padding()
    }
}
