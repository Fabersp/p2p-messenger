//
//  ContentView.swift
//  SecureChat
//
//  Created by Fabricio Padua on 6/1/25.
//

import SwiftUI

struct ContentView: View {
    @State private var userInfo: UserInfo? = ProfileHelper.getUserInfo()
    @StateObject private var peerManagerHolder = PeerManagerHolder()
    
    @ViewBuilder
    var body: some View {
        if let user = userInfo, let peerManager = peerManagerHolder.peerManager {
            UserListView(peerManager: peerManager)
                .id(user.email)
        } else {
            UserOnboardingView { newUserInfo in
                userInfo = newUserInfo
                ProfileHelper.saveUserInfo(newUserInfo)
                peerManagerHolder.peerManager = PeerManager(userInfo: newUserInfo)
            }
        }
    }
}

class PeerManagerHolder: ObservableObject {
    @Published var peerManager: PeerManager? = nil
}
