//
//  SignedMessage.swift
//  SecureChat
//
//  Created by Fabricio Padua on 6/6/25.
//

import Foundation

struct SignedMessage: Codable, Identifiable {
    let id = UUID()
    let text: String
    let signature: Data
    let senderPublicKey: Data
    let senderName: String
}

