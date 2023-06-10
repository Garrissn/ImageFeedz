//
//  ImagesListTests.swift
//  ImageFeedzTests
//
//  Created by Игорь Полунин on 10.06.2023.
//

import Foundation
import XCTest
@testable import ImageFeedz

final class ImagesListTest: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        // given
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        
        let presenter = WebViewPresenterSpy()
        
//        viewController.presenter = presenter
//        presenter.view = viewController
//
        
        //when
        
        _ = viewController.view
        
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    
    
}
