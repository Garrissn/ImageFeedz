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
//class MockPresentingViewController: UIViewController {
//    var presentedViewController: UIAlertController?
//
//            override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
//                presentedViewController = viewControllerToPresent as? UIAlertController
//                completion?()
//            }

    //}
