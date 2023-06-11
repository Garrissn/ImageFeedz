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
        XCTAssertFalse(imagesListService.fetchPhotosNextPageCalled, "е должен вызывать фечнекстфото")
        XCTAssertEqual(viewController.loadTableViewCallsCount, 0, "вью не должен вызывать loadTableView")
    }
    
    func testImageListCellDidTapLike() {
        // Given
        enum MockError: Error {
            case someError
        }
        let viewController = ImagesListViewControllerSpy()
        let imagesListService = ImagesListServiceMock()
        
        let presenter = ImagesListPresenter(imagesListService: imagesListService, view: viewController)
        let indexPath = IndexPath(row: 0, section: 0)
        let expectedIsLike = false
        
        let photo = Photo(id: "photo1",
                          size: CGSize(width: 100, height: 100),
                          createdAt: "2023-05-17T10:00:00Z",
                          welcomeDescription: "Description",
                          thumbImageURL: "photo1.jpg",
                          largeImageURL: "photo1.jpg", isLiked: false)
        
        presenter.photos = [photo]
        imagesListService.mockChangeLikeResult = .failure(MockError.someError)
        
        // When
        
        let expectation = XCTestExpectation(description: "Like completion called")
        presenter.imageListCellDidTapLike(indexPath: indexPath) { isLike in
            XCTAssertEqual(isLike, expectedIsLike)
            expectation.fulfill()
        }
        
        
        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(viewController.blockShow)
        XCTAssertTrue(viewController.blockHide)
        XCTAssertTrue(imagesListService.changeLikeCalled)
        XCTAssertEqual(imagesListService.changeLikePhotoId, "photo1")
        XCTAssertEqual(imagesListService.changeLikeIsLike, false)
    }
    
    func testConfigureCell() {
        // Given
        let viewController = ImagesListViewControllerSpy()
        let imagesListService = ImagesListServiceMock()
        
        let presenter = ImagesListPresenter(imagesListService: imagesListService, view: viewController)
        let indexPath = IndexPath(row: 0, section: 0)
        
        let photo = Photo(id: "photo1",
                          size: CGSize(width: 100, height: 100),
                          createdAt: "2023-05-17T10:00:00Z",
                          welcomeDescription: "Description",
                          thumbImageURL: "https://yandex.ru/photo1.jpg",
                          largeImageURL: "https://yandex.ru/photo1.jpg",
                          isLiked: false)
        presenter.photos = [photo]
        
        // When
        let result = presenter.configureCell(indexPath: indexPath)
        
        // Then
        XCTAssertEqual(result.url.absoluteString, "https://yandex.ru/photo1.jpg")
        XCTAssertEqual(result.formattedData, "17 мая 2023")
    }

}
