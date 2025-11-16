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
    @State private var userType = "General User"
    
    let userTypes = ["General User", "Chef"]
    

    var body: some View {
        VStack(spacing: 16) {
            Text("Create Account")
                .font(.largeTitle.bold())

            TextField("Display Name (optional)", text: $displayName)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)

            TextField("Email", text: $email)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)

            SecureField("Password (min 6)", text: $password)
                .textFieldStyle(.roundedBorder)
            
            Picker("Select Account Type", selection: $userType) {
                ForEach(userTypes, id: \.self) { type in
                    Text(type).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            Button {
                Task { await auth.signUp(email: email, password: password, displayName: displayName.isEmpty ? nil : displayName, userType: userType) }
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

