//
//  PrivateChatView.swift
//  SecureChat
//
//  Created by Fabricio Padua on 6/6/25.
//

import SwiftUI

struct PrivateChatView: View {
    @ObservedObject var peerManager: PeerManager
    let targetUser: UserInfo
    @State private var messageText = ""

    var body: some View {
        VStack {
            List(peerManager.privateMessages[targetUser.email] ?? []) { msg in
                HStack(alignment: .top) {
                    if msg.senderName == "\(peerManager.userInfo.firstName) \(peerManager.userInfo.lastName)" {
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(msg.text)
                                .padding(8)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                            Text("Você")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    } else {
                        VStack(alignment: .leading) {
                            Text(msg.text)
                                .padding(8)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(8)
                            Text(msg.senderName)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                }
            }
            HStack {
                TextField("message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("send") {
                    let user = peerManager.userInfo
                    let fullName = "\(user.firstName) \(user.lastName)"
                    if !messageText.trimmingCharacters(in: .whitespaces).isEmpty {
                        if let signed = CryptoHelper.shared.sign(message: messageText, senderName: fullName) {
                            peerManager.sendPrivate(signed, to: targetUser.email)
                            messageText = ""
                        }
                    }
                }
                .disabled(messageText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
        }
        .navigationTitle("\(targetUser.firstName) \(targetUser.lastName)")
        .onAppear {
            peerManager.currentlyOpenChatEmail = targetUser.email
            peerManager.unreadUsers.remove(targetUser.email)
        }
        .onDisappear {
            peerManager.currentlyOpenChatEmail = nil
        }
    }
}
