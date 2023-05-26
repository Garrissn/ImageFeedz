//
//  ImageFeedzTests.swift
//  ImageFeedzTests
//
//  Created by Игорь Полунин on 24.03.2023.
//

import XCTest
@testable import ImageFeedz

final class ImagesListServiceTests: XCTestCase {

    func testFetchPhotos() {
        let service = ImagesListService()
        
        let expectation = self.expectation(description: "Wait for Notification")
                NotificationCenter.default.addObserver(
                    forName: ImagesListService.DidChangeNotification,
                    object: nil,
                    queue: .main) { _ in
                        expectation.fulfill()
                    }
                
        service.fetchPhotosNextPage()
                wait(for: [expectation], timeout: 10)
                
                XCTAssertEqual(service.photos.count, 10)
        service.fetchPhotosNextPage()
        
    }
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    


