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
        
        let presenter = ImagesListPresenterSpy()
        
       viewController.presenter = presenter
       presenter.view = viewController

        
        //when
       
        _ = viewController.view
       
        
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
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
    
   
    
    

   

   
        
    func testWillDisplayShouldFetchNextPageWhenReachedEndOfPhotos() {
        // Given
        
        let viewController = ImagesListViewControllerSpy()
        let imagesListService = ImagesListServiceMock()
       
        let presenter = ImagesListPresenter(imagesListService: imagesListService, view: viewController)
       
        
       viewController.presenter = presenter
       presenter.view = viewController
        
        
        let indexPath = IndexPath(row: imagesListService.photos.count - 1, section: 0)
        
        // When
        presenter.willDisplay(indexPath: indexPath)
        
        // Then
        XCTAssertTrue(imagesListService.fetchPhotosNextPageCalled, "Вызов следующих Фото")
        XCTAssertEqual(viewController.loadTableViewCallsCount, 0, "не должен грузить лоадтейблвью")
    }

    func testWillDisplayShouldNotFetchNextPageWhenNotReachedEndOfPhotos() {
        // Given
        
        let viewController = ImagesListViewControllerSpy()
        let imagesListService = ImagesListServiceMock()
       
        let presenter = ImagesListPresenter(imagesListService: imagesListService, view: viewController)
       
        
       viewController.presenter = presenter
       presenter.view = viewController
        
        let indexPath = IndexPath(row: 0, section: 0)
        
        // When
        presenter.willDisplay(indexPath: indexPath)
        
        // Then
        XCTAssertFalse(imagesListService.fetchPhotosNextPageCalled, "не должен вызывать фечнекстфото")
        XCTAssertEqual(viewController.loadTableViewCallsCount, 0, "вью не должен вызывать loadTableView")
    }
    
    func testWillDisplayShouldNotFetchNextPageWhenNoPhotos() {
        // Given
        let viewController = ImagesListViewControllerSpy()
        let imagesListService = ImagesListServiceMock()
       
        let presenter = ImagesListPresenter(imagesListService: imagesListService, view: viewController)
       
        
       viewController.presenter = presenter
       presenter.view = viewController
        
        let indexPath = IndexPath(row: 0, section: 0)
        imagesListService.photos = []
        
        // When
        presenter.willDisplay(indexPath: indexPath)
        
        // Then
        XCTAssertFalse(imagesListService.fetchPhotosNextPageCalled, "Should not fetch next page")
        XCTAssertEqual(viewController.loadTableViewCallsCount, 0, "Should not call loadTableView")
    }

}
