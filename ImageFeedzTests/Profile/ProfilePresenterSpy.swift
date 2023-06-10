//
//  ProfilePresenterSpy.swift
//  ImageFeedzTests
//
//  Created by Игорь Полунин on 09.06.2023.
//

import Foundation
@testable import ImageFeedz
import UIKit

final class ProfilePresenterSpy: ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    var logoutButtonTappedCalled: Bool = false
    var presentingViewController: UIViewController?
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func logoutButtonTapped(presentingViewController: UIViewController) {
        logoutButtonTappedCalled = true
        self.presentingViewController = presentingViewController
    }
    
    func setupPrifileImageObserver() {
        
    }
}
