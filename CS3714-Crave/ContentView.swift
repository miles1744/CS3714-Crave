//
//  ContentView.swift
//  CS3714-Crave
//
//  Created by Miles Thomas on 11/3/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ContentView: View {
    @State private var status = "Tap a button to test Firebase"

    var body: some View {
        VStack(spacing: 20) {
            Text("Firebase Test")
                .font(.largeTitle.bold())

            Text(status)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()

            Button("Test Sign Up") {
                Task { await createUser() }
            }
            .buttonStyle(.borderedProminent)

            Button("Test Firestore") {
                Task { await writeAndReadFirestore() }
            }
            .buttonStyle(.bordered)

            Spacer()
        }
        .padding()
    }

    // MARK: - Test Functions
    private func createUser() async {
        do {
            let email = "test\(Int.random(in: 0...9999))@example.com"
            let password = "password123"

            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            status = "Created user: \(result.user.uid)\nEmail: \(email)"
        } catch {
            status = "Auth error: \(error.localizedDescription)"
        }
    }

    private func writeAndReadFirestore() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            status = "No signed-in user. Run 'Test Sign Up' first."
            return
        }

        let db = Firestore.firestore()
        let docRef = db.collection("users").document(uid)

        do {
            try await docRef.setData([
                "uid": uid,
                "createdAt": Timestamp(date: Date()),
                "message": "Hello from SwiftUI!"
            ])

            let snapshot = try await docRef.getDocument()
            if let data = snapshot.data() {
                status = "Firestore write/read success:\n\(data)"
            } else {
                status = "No data found."
            }
        } catch {
            status = "Firestore error: \(error.localizedDescription)"
        }
    }
}
