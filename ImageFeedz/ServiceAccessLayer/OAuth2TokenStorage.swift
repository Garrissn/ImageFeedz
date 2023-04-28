//
//  OAuth2TokenStorage.swift
//  ImageFeedz
//
//  Created by Игорь Полунин on 26.04.2023.
//

import Foundation

final class OAuth2TokenStorage {
    private let userDefaults = UserDefaults.standard
    var token: String? {
        get {
         let token = userDefaults.string(forKey: "token")
            return token
        }
        set{
            userDefaults.set(newValue, forKey: "token")
            
        }
    }
}
