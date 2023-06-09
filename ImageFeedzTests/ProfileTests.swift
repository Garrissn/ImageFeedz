//
//  ImageListTests.swift
//  ImageFeedzTests
//
//  Created by Игорь Полунин on 09.06.2023.
//

import XCTest
@testable import ImageFeedz


final class ProfileTests: XCTestCase {
    
    func testProfileViewControllerCallsViewDidLoad() {
        //given
        
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsUpdateAvatar() {
        //given
        let profileViewController = ProfileViewControllerSpy()
        let profileService = ProfileService.shared
        let profileImageService = ProfileImageService.shared
        let tokenStorage = OAuth2TokenStorage()

        let presenter = ProfileViewPresenter(view: profileViewController, profileService: profileService, profileImageService: profileImageService, tokenStorage: tokenStorage)
        profileViewController.presenter = presenter

        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(profileViewController.updateAvatar)
    }
    
    
    func testPresenterCallsUpdateProfileDetails() {
        //given
        let profileViewController = ProfileViewControllerSpy()
       
        let profileService = ProfileService.shared
        let profileImageService = ProfileImageService.shared
        let tokenStorage = OAuth2TokenStorage()

        let presenter = ProfileViewPresenter(view: profileViewController, profileService: profileService, profileImageService: profileImageService, tokenStorage: tokenStorage)
        profileViewController.presenter = presenter
       
        
        //when
        presenter.viewDidLoad()
        
        
        //then
        XCTAssertTrue(profileViewController.updateProfile)
    }
    
    func testProfilePresenterCallsLogoutButtonTapped() {
        //given
        
        let presentingViewController = UIViewController()
        let presenter = ProfilePresenterSpy()
       
        
        //when
        
        presenter.logoutButtonTapped(presentingViewController: presentingViewController)
        
        
        //then
        XCTAssertTrue(presenter.logoutButtonTappedCalled)
        XCTAssertEqual(presenter.presentingViewController, presentingViewController)
    }
    
    func testSetupProfileImageObserver() {
        // Given
        let profileViewController = ProfileViewControllerSpy()
        let profileService = ProfileService.shared
        let profileImageService = ProfileImageService.shared
        let tokenStorage = OAuth2TokenStorage()
        let presenter = ProfileViewPresenter(view: profileViewController, profileService: profileService, profileImageService: profileImageService, tokenStorage: tokenStorage)
        profileViewController.presenter = presenter
        
        // When
        presenter.setupPrifileImageObserver()
        
        
        
        // Then
        XCTAssertNotNil(presenter.setupPrifileImageObserver)
    }
}
