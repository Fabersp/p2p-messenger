//
//  UserListView.swift
//  SecureChat
//
//  Created by Fabricio Padua on 6/6/25.
//

import SwiftUI

struct UserListView: View {
    @ObservedObject var peerManager: PeerManager
    @State private var selectedEmail: String? = nil

    var filteredUsers: [UserInfo] {
        peerManager.knownUsers.values
            .filter { $0.email != peerManager.userInfo.email }
            .sorted { $0.firstName < $1.firstName }
    }

    var isPhone: Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .phone
        #else
        return false
        #endif
    }

    var body: some View {
        Group {
            if isPhone {
                NavigationStack {
                    List(filteredUsers) { user in
                        NavigationLink(destination: PrivateChatView(peerManager: peerManager, targetUser: user)) {
                            UserRow(user: user,
                                    isOnline: peerManager.connectedPeersNames.contains(user.email),
                                    hasUnread: peerManager.unreadUsers.contains(user.email))
                        }
                    }
                    .navigationTitle("Users")
                }
            } else {
                NavigationSplitView {
                    List(selection: $selectedEmail) {
                        ForEach(filteredUsers, id: \.email) { user in
                            UserRow(user: user,
                                    isOnline: peerManager.connectedPeersNames.contains(user.email),
                                    hasUnread: peerManager.unreadUsers.contains(user.email))
                                .tag(user.email) // Usa email como ID da seleção
                        }
                    }
                    .navigationTitle("User")
                } detail: {
                    if let email = selectedEmail,
                       let user = filteredUsers.first(where: { $0.email == email }) {
                        PrivateChatView(peerManager: peerManager, targetUser: user)
                    } else {
                        Text("Select someone to chat...")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct UserRow: View {
    let user: UserInfo
    let isOnline: Bool
    let hasUnread: Bool

    var body: some View {
        HStack {
            Text("\(user.firstName) \(user.lastName) • \(user.department)")
            Spacer()
            if hasUnread {
                Circle()
                    .fill(Color.red)
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 2)
            } else {
                Circle()
                    .fill(isOnline ? Color.green : Color.gray)
                    .frame(width: 10, height: 10)
            }
        }
    }
}
