//
//  OAuth2TokenStorage.swift
//  ImageFeedz
//
//  Created by Игорь Полунин on 26.04.2023.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let keychain = KeychainWrapper.standard
    var token: String? {
        get {
            
            let token = keychain.string(forKey: "token")
            return token
        }
        set {
            if let newToken = newValue {
                keychain.set(newToken, forKey: "token")
            }
            else { keychain.removeObject(forKey: "token") }
            
        }
    }
    func cleanToken() {
        OAuth2TokenStorage().token = nil
    }
}
