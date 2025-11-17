//
//  LoginView.swift
//  CS3714-Crave
//
//  Created by Brendan Michael Riordan on 11/9/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @FocusState private var focused: Field?

    enum Field {
        case email
        case password
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome Back")
                .font(.largeTitle.bold())

            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
                .focused($focused, equals: .email)
                .submitLabel(.next)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .focused($focused, equals: .password)
                .submitLabel(.go)

            Button {
                Task { await auth.signIn(email: email, password: password) }
            } label: {
                HStack {
                    if auth.loading { ProgressView() }
                    Text("Log In")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(email.isEmpty || password.count < 6)

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
        // Handle return key
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
