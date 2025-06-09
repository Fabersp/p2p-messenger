//
//  CryptoHelper.swift
//  SecureChat
//
//  Created by Fabricio Padua on 6/1/25.
//

import Foundation
import CryptoKit

class CryptoHelper {
    static let shared = CryptoHelper()
    private let keychainKey = "securechat_private_key"
    private(set) var privateKey: P256.Signing.PrivateKey
    var publicKey: P256.Signing.PublicKey { privateKey.publicKey }
    
    private init() {
        if let savedKeyData = KeychainHelper.load(key: keychainKey) {
            if let key = try? P256.Signing.PrivateKey(rawRepresentation: savedKeyData) {
                privateKey = key
                return
            }
        }
        privateKey = P256.Signing.PrivateKey()
        _ = KeychainHelper.save(key: keychainKey, data: privateKey.rawRepresentation)
    }
    
    func sign(message: String, senderName: String) -> SignedMessage? {
        guard let messageData = message.data(using: .utf8) else { return nil }
        guard let signature = try? privateKey.signature(for: messageData) else { return nil }
        let rawSignature = signature.rawRepresentation
        let publicKeyData = publicKey.rawRepresentation
        return SignedMessage(text: message, signature: rawSignature, senderPublicKey: publicKeyData, senderName: senderName)
    }
    
    static func verify(signedMessage: SignedMessage) -> Bool {
        guard let messageData = signedMessage.text.data(using: .utf8) else { return false }
        guard let senderKey = try? P256.Signing.PublicKey(rawRepresentation: signedMessage.senderPublicKey) else { return false }
        guard let signature = try? P256.Signing.ECDSASignature(rawRepresentation: signedMessage.signature) else { return false }
        return senderKey.isValidSignature(signature, for: messageData)
    }
}
