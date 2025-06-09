//
//  PeerManager.swift
//  SecureChat
//
//  Created by Fabricio Padua on 6/1/25.
//

import SwiftUI
import CryptoKit
import MultipeerConnectivity

enum OnboardingPacket: Codable {
    case checkEmail(String)
    case emailCheckResponse(isTaken: Bool)
    case updateUserInfo(UserInfo)
}

class PeerManager: NSObject, ObservableObject {
    private let serviceType = "secure-chat"
    let myPeerId: MCPeerID

    @Published var userInfo: UserInfo
    @Published var knownUsers: [String: UserInfo] = [:]
    @Published var connectedPeersNames: [String] = []
    @Published var messages: [SignedMessage] = []
    @Published var privateMessages: [String: [SignedMessage]] = [:]
    @Published var unreadUsers: Set<String> = []
    var currentlyOpenChatEmail: String? = nil
    
    private let session: MCSession
    private let advertiser: MCNearbyServiceAdvertiser
    private let browser: MCNearbyServiceBrowser

    // MARK: - Init

    init(userInfo: UserInfo) {
        self.userInfo = userInfo
        self.myPeerId = MCPeerID(displayName: userInfo.email)
        self.session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        self.advertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        self.browser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)

        super.init()
        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
        self.knownUsers[userInfo.email] = userInfo
    }

    // MARK: - send message
    
    func send(_ signedMessage: SignedMessage) {
        guard !session.connectedPeers.isEmpty else { return }
        guard let data = try? JSONEncoder().encode(signedMessage) else { return }
        try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
        DispatchQueue.main.async { self.messages.append(signedMessage) }
    }
    
    // MARK: - sendPrivate
    
    func sendPrivate(_ signedMessage: SignedMessage, to targetEmail: String) {
        guard let peer = session.connectedPeers.first(where: { $0.displayName == targetEmail }) else { return }
        guard let data = try? JSONEncoder().encode(signedMessage) else { return }
        do {
            try session.send(data, toPeers: [peer], with: .reliable)
            DispatchQueue.main.async {
                self.privateMessages[targetEmail, default: []].append(signedMessage)
            }
        } catch {
            print("error to send private message: \(error)")
        }
    }

    // MARK: - Onboarding e Broadcast

    func checkEmailWithPeers(_ email: String, completion: @escaping (Bool) -> Void) {
        guard !session.connectedPeers.isEmpty else {
            completion(false)
            return
        }
        let packet = OnboardingPacket.checkEmail(email)
        guard let data = try? JSONEncoder().encode(packet) else {
            completion(false)
            return
        }
        var emailTaken = false
        var replies = 0
        let expected = session.connectedPeers.count
        let handler: (Bool) -> Void = { taken in
            if taken { emailTaken = true }
            replies += 1
            if replies == expected || emailTaken {
                completion(emailTaken)
            }
        }
        self.emailCheckResponseHandler = handler
        try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if replies < expected {
                completion(emailTaken)
            }
        }
    }

    private var emailCheckResponseHandler: ((Bool) -> Void)?

    // MARK: - update name and department

    func updateMyNameAndDepartment(firstName: String, lastName: String, department: String) {
        userInfo = UserInfo(firstName: firstName,
                            lastName: lastName,
                            email: userInfo.email,
                            department: department,
                            publicKey: userInfo.publicKey)
        knownUsers[userInfo.email] = userInfo
        broadcastUserInfo()
    }
    
    private func broadcastUserInfo() {
        let packet = OnboardingPacket.updateUserInfo(userInfo)
        guard let data = try? JSONEncoder().encode(packet) else { return }
        try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }

    // MARK: - receved packet

    private func handlePacket(_ packet: OnboardingPacket, from peer: MCPeerID) {
        switch packet {
        case .checkEmail(let email):
            let isTaken = (email == userInfo.email) || knownUsers.keys.contains(email)
            let response = OnboardingPacket.emailCheckResponse(isTaken: isTaken)
            if let respData = try? JSONEncoder().encode(response) {
                try? session.send(respData, toPeers: [peer], with: .reliable)
            }
        case .emailCheckResponse(let isTaken):
            emailCheckResponseHandler?(isTaken)
        case .updateUserInfo(let info):
            DispatchQueue.main.async {
                self.knownUsers[info.email] = info
            }
        }
    }
}

extension PeerManager: MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            DispatchQueue.main.async {
                self.connectedPeersNames.removeAll(where: { $0 == peerID.displayName })
            }
        case .connecting:
            break
        case .connected:
            DispatchQueue.main.async {
                if !self.connectedPeersNames.contains(peerID.displayName) {
                    self.connectedPeersNames.append(peerID.displayName)
                }
                self.broadcastUserInfo()
            }
        @unknown default: break
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let packet = try? JSONDecoder().decode(OnboardingPacket.self, from: data) {
            handlePacket(packet, from: peerID)
            return
        }
        if let message = try? JSONDecoder().decode(SignedMessage.self, from: data) {
            let senderEmail = peerID.displayName
            if self.privateMessages[senderEmail] != nil || self.knownUsers[senderEmail] != nil {
                DispatchQueue.main.async {
                    self.privateMessages[senderEmail, default: []].append(message)
                    // Badge se não for o chat aberto
                    if self.currentlyOpenChatEmail != senderEmail {
                        self.unreadUsers.insert(senderEmail)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.messages.append(message)
                }
            }
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {}
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {}
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.connectedPeersNames.removeAll(where: { $0 == peerID.displayName })
        }
    }
}
