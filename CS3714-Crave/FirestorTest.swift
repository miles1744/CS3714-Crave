//
//  FirestorTest.swift
//  CS3714-Crave
//
//  Created by Brendan Michael Riordan on 11/9/25.
//

import FirebaseFirestore
import FirebaseAuth

func demoWriteRead() {
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser?.uid ?? "anon"
    let docRef = db.collection("users").document(uid)

    Task {
        do {
            try await docRef.setData(["uid": uid, "email": "test@example.com", "createdAt": Date()])
            let snap = try await docRef.getDocument()
            print("Doc data:", snap.data() ?? [:])
        } catch {
            print("Firestore error:", error.localizedDescription)
        }
    }
}
