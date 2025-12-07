//
//  LoginView.swift
//  CS3714-Crave
//
//  Created by Brendan Michael Riordan on 11/9/25.
//

import SwiftUI

/// View that handles user login with email and password
struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel  // Access the shared authentication state

    @State private var email = ""               // Email input
    @State private var password = ""            // Password input

    // Field focus state for keyboard navigation
    @FocusState private var focused: Field?

    // Enum to track which field is currently focused
    enum Field {
        case email
        case password
    }

    var body: some View {
        VStack(spacing: 16) {
            // App title
            Text("Welcome Back")
                .font(.largeTitle.bold())

            // Email input field
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
                .focused($focused, equals: .email)   // Autofocus support
                .submitLabel(.next)                  // "Next" on keyboard

            // Password input field
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .focused($focused, equals: .password)
                .submitLabel(.go)                    // "Go" on keyboard

            // Log In button
            Button {
                Task { await auth.signIn(email: email, password: password) }
            } label: {
                HStack {
                    if auth.loading { ProgressView() }  // Show loading spinner if authenticating
                    Text("Log In")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(email.isEmpty || password.count < 6)  // Disable if inputs are invalid

            // Display authentication error message if one exists
            if let err = auth.errorMessage {
                Text(err)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding()

        // 👉 Force initial focus on email when the screen appears
        .onAppear {
            focused = .email
        }

        // Handle keyboard return key based on focused field
        .onSubmit {
            switch focused {
            case .email:
                focused = .password
            case .password:
                Task { await auth.signIn(email: email, password: password) }
            case .none:
                break
            }
        }
    }
}
