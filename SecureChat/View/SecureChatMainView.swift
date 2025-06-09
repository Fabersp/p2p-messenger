//
//  SecureChatMainView.swift
//  SecureChat
//
//  Created by Fabricio Padua on 6/6/25.
//

import SwiftUI

struct SecureChatMainView: View {
    @ObservedObject var peerManager: PeerManager
    @State private var messageText = ""
    
    var body: some View {
        VStack {
            if peerManager.connectedPeersNames.isEmpty {
                Text("no device connected")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                Text("Conected with device: \(peerManager.connectedPeersNames.joined(separator: ", "))")
                    .foregroundColor(.green)
                    .padding()
            }
            List(peerManager.messages) { msg in
                VStack(alignment: .leading) {
                    Text(msg.text).fontWeight(.bold)
                    HStack {
                        if let user = peerManager.knownUsers.first(where: { $0.value.firstName + " " + $0.value.lastName == msg.senderName })?.value {
                            Text("from: \(user.firstName) \(user.lastName) • \(user.department)")
                                .font(.caption)
                        } else {
                            Text("from: \(msg.senderName)")
                                .font(.caption)
                        }
                        Spacer()
                        Text(CryptoHelper.verify(signedMessage: msg) ? "Signatured" : "invalid signature")
                            .font(.caption)
                            .foregroundColor(CryptoHelper.verify(signedMessage: msg) ? .green : .red)
                    }
                }
            }
            HStack {
                TextField("message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("send") {
                    let user = peerManager.userInfo
                    let fullName = "\(user.firstName) \(user.lastName)"
                    if let signed = CryptoHelper.shared.sign(message: messageText, senderName: fullName) {
                        peerManager.send(signed)
                        messageText = ""
                    }
                }
            }.padding()
        }
    }
}
