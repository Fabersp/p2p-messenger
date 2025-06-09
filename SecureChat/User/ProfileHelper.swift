//
//  ProfileHelper.swift
//  SecureChat
//
//  Created by Fabricio Padua on 6/6/25.
//

import Foundation

struct ProfileHelper {
    static let userInfoKey = "securechat_user_info"
    static func saveUserInfo(_ user: UserInfo) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: userInfoKey)
        }
    }
    static func getUserInfo() -> UserInfo? {
        if let data = UserDefaults.standard.data(forKey: userInfoKey),
           let user = try? JSONDecoder().decode(UserInfo.self, from: data) {
            return user
        }
        return nil
    }
    static func clearUserInfo() {
        UserDefaults.standard.removeObject(forKey: userInfoKey)
    }
}

