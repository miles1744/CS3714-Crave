//
//  SignUpView.swift
//  CS3714-Crave
//
//  Created by Brendan Michael Riordan on 11/9/25.
//

import SwiftUI

/// View for creating a new account — allows users to choose between General User and Chef roles
struct SignUpView: View {
    @EnvironmentObject var auth: AuthViewModel   // Access shared authentication logic

    // Form input states
    @State private var displayName = ""          // Optional display name
    @State private var email = ""                // Required email
    @State private var password = ""             // Required password

    // Default role for new user; either "General User" or "Chef"
    @State private var userType = "General User"   //internal value

    var body: some View {
        VStack(spacing: 16) {
            // Header
            Text("Create Account")
                .font(.largeTitle.bold())

            // Display name input
            TextField("Display Name (optional)", text: $displayName)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)

            // Email input
            TextField("Email", text: $email)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)

            // Password input (secure)
            SecureField("Password (min 6)", text: $password)
                .textFieldStyle(.roundedBorder)

            // Role picker 
            // Use labels, but tags must match backend-friendly values
            Picker("Select Account Type", selection: $userType) {
                Text("General User").tag("General User")
                Text("Chef").tag("Chef")
            }
            .pickerStyle(SegmentedPickerStyle())

            // Sign Up button
            Button {
                Task {
                    await auth.signUp(
                        email: email,
                        password: password,
                        displayName: displayName.isEmpty ? nil : displayName,
                        userType: userType          // "General User" or "Chef"
                    )
                }
            } label: {
                HStack {
                    if auth.loading { ProgressView() }  // Show loading spinner
                    Text("Sign Up")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(email.isEmpty || password.count < 6) // Basic input validation

            // Show any sign-up error messages
            if let err = auth.errorMessage {
                Text(err)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding()
    }
}
