//
//  UserOnboardingView.swift
//  SecureChat
//
//  Created by Fabricio Padua on 6/6/25.
//

import SwiftUI

struct UserOnboardingView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var department: String = ""
    @State private var emailTaken = false
    @State private var isChecking = false

    var onComplete: (UserInfo) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Wellcome to SecureChat!").font(.title)
            Text("Fill in your details to join the internal network..").foregroundColor(.secondary)
            TextField("First Name", text: $firstName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Last name", text: $lastName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("E-mail", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            TextField("Department", text: $department)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            if emailTaken {
                Text("This email address is already in use!")
                    .foregroundColor(.red)
            }
            Button(isChecking ? "Checking..." : "Contunue") {
                isChecking = true
                let pubKey = CryptoHelper.shared.publicKey.rawRepresentation
                let user = UserInfo(firstName: firstName, lastName: lastName, email: email, department: department, publicKey: pubKey)
                onComplete(user)
                isChecking = false
            }
            .disabled(isChecking || firstName.isEmpty || lastName.isEmpty || email.isEmpty || department.isEmpty)
            .padding()
        }
        .frame(maxWidth: 400)
        .padding()
    }
}
