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
    
    func testViewControllerCallssetupImageListServiceObserver() {
        // given
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        
        let presenter = ImagesListPresenterSpy()
        
       viewController.presenter = presenter
       presenter.view = viewController

        
        //when
        _ = viewController.view
       // presenter.setupImageListServiceObserver()
        
        
        //then
        XCTAssertTrue(presenter.setupImageList)
    }
    
    func testPresenterCallsLoadTableView() {
        // given
        
        let viewController = ImagesListViewControllerSpy()
        let imagesListService = ImagesListService.shared
        
        
        let presenter = ImagesListPresenter(imagesListService: imagesListService, view: viewController)
        
       viewController.presenter = presenter
       presenter.view = viewController

        
        //when
        presenter.updateTableViewAnimated()
       
        
        
        //then
        XCTAssertTrue(viewController.loadTable)
    }
    
    func testViewContrillerCallsBlockingProgress() {
        // given
        
        let viewController = ImagesListViewControllerSpy()
        let imagesListService = ImagesListService.shared
       
        let presenter = ImagesListPresenter(imagesListService: imagesListService, view: viewController)
       
        
       viewController.presenter = presenter
       presenter.view = viewController

        
        //when
        presenter.imageListCellDidTapLike(indexPath: <#T##IndexPath#>, completion: <#T##(Bool) -> Void#>)
        
        
        
        //then
        XCTAssertTrue(viewController.blockHide)
    }
    
    func testViewControllerCallsConfigureCell() {
        // given
        
        let viewController = ImagesListViewControllerSpy()
        let imagesListService = ImagesListMock()
       
        let presenter = ImagesListPresenter(imagesListService: imagesListService, view: viewController)
       
        
       viewController.presenter = presenter
       presenter.view = viewController

        
        //when
        presenter.configureCell(indexPath: <#T##IndexPath#>)
        
        
        
        //then
        XCTAssertTrue(viewController.)
    }
    

}
