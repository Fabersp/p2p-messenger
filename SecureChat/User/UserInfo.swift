//
//  UserInfo.swift.swift
//  SecureChat
//
//  Created by Fabricio Padua on 6/6/25.
//

import Foundation

struct UserInfo: Codable, Hashable, Identifiable {
    var id: String { email }
    let firstName: String
    let lastName: String
    let email: String
    var department: String
    let publicKey: Data
}
