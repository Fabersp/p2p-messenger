//
//  UserProfileEditView.swift
//  SecureChat
//
//  Created by Fabricio Padua on 6/6/25.
//

import SwiftUI

struct UserProfileEditView: View {
    @ObservedObject var peerManager: PeerManager
    @State private var firstName: String
    @State private var lastName: String
    @State private var department: String
    @Environment(\.presentationMode) var presentationMode

    init(peerManager: PeerManager) {
        self.peerManager = peerManager
        _firstName = State(initialValue: peerManager.userInfo.firstName)
        _lastName = State(initialValue: peerManager.userInfo.lastName)
        _department = State(initialValue: peerManager.userInfo.department)
    }

    var body: some View {
        Form {
            Section(header: Text("User Information")) {
                TextField("First Name", text: $firstName)
                TextField("Last Name", text: $lastName)
                TextField("Department", text: $department)
                TextField("Email", text: .constant(peerManager.userInfo.email))
                    .disabled(true)
                    .foregroundColor(.gray)
            }
            Button("Save Changes") {
                peerManager.updateMyNameAndDepartment(firstName: firstName, lastName: lastName, department: department)
                presentationMode.wrappedValue.dismiss()
            }
            .disabled(
                firstName.trimmingCharacters(in: .whitespaces).isEmpty ||
                lastName.trimmingCharacters(in: .whitespaces).isEmpty ||
                department.trimmingCharacters(in: .whitespaces).isEmpty
            )
        }
        .navigationTitle("Edit Profile")
    }
}
