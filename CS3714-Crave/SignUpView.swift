//
//  SignUpView.swift
//  CS3714-Crave
//
//  Created by Brendan Michael Riordan on 11/9/25.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Create Account")
                .font(.largeTitle.bold())

            TextField("Display Name (optional)", text: $displayName)
                .textFieldStyle(.roundedBorder)

            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)

            SecureField("Password (min 6)", text: $password)
                .textFieldStyle(.roundedBorder)

            Button {
                Task { await auth.signUp(email: email, password: password, displayName: displayName.isEmpty ? nil : displayName) }
            } label: {
                HStack {
                    if auth.loading { ProgressView() }
                    Text("Sign Up")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(email.isEmpty || password.count < 6)

            if let err = auth.errorMessage {
                Text(err).foregroundStyle(.red).font(.footnote).multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding()
    }
}

