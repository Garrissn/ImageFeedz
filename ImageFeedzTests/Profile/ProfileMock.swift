//
//  ProfileMock.swift
//  ImageFeedzTests
//
//  Created by Игорь Полунин on 10.06.2023.
//


import Foundation
@testable import ImageFeedz
import UIKit

class MockTokenStorage: OAuth2TokenStorageProtocol {
    var token: String?
    
       var cleanTokenCalled = false
       
       func cleanToken() {
           cleanTokenCalled = true
       }
   }

class MockWebViewController {
       static var cleanCalled = false

    static func clean() {
           cleanCalled = true
       }
   }
class ProfileImageServiceMock: ProfileImageServiceProtocol {
    var avatarURL: String? = "https://example.com/avatar.jpg"
    
    
}
class ProfileServiceMock: ProfileServiceProtocol {
    
    
   
    
    var profile: Profile? = Profile(username: "String?",
                          name: "String?",
                          loginName: "String?",
                          bio: "String?")
    
}

