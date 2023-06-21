//
//  ImageFeedzTests.swift
//  ImageFeedzTests
//
//  Created by Игорь Полунин on 24.03.2023.
//

import XCTest
@testable import ImageFeedz


final class WebViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        // given
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        
        //when
        
        _ = viewController.view
        
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest () {
        
        // given
        
        let viewController = WebViewControlllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController
        
        
        //when
        
        presenter.viewDidLoad()
        
        //then
        
        XCTAssertTrue(viewController.loadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        // given
        
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        
        let progress: Float = 0.6
        
        //when
        
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //Then
        
        XCTAssertFalse(shouldHideProgress)
        
        
    }
    
    func testProgressHiddenWhenOne() {
        
        // given
        
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        
        let progress: Float = 1
        
        //when
        
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //Then
        
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        // given
        
        let configuration = AuthConfiguration.standart
        let authHelper = AuthHelper(configuration: configuration)
        
        //when
        
        let url = authHelper.authURL()
        let urlString = url.absoluteString
        
        
        //Then
        
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        
    }
    func testCodeFromURL() {
        
        // given
        
        let configuration = AuthConfiguration.standart
        let authHelper = AuthHelper(configuration: configuration)
        
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [
        URLQueryItem(name: "code", value: "testCode")
        ]
        
        let url = urlComponents.url!
        
        //when
        
        let code = authHelper.code(from: url)
        
        
        //Then
        
        XCTAssertEqual(code, "testCode")
        
    }
    
    }


    


