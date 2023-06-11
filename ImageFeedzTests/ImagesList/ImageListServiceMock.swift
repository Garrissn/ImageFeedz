//
//  ImageListMock.swift
//  ImageFeedzTests
//
//  Created by Игорь Полунин on 10.06.2023.
//



import Foundation
@testable import ImageFeedz

final class  ImagesListServiceMock: ImagesListServiceProtocol {
    var photos: [ImageFeedz.Photo] = []
    
    
    var fetchPhotosNextPageCalled = false
    
    var changeLikeCalled = false
    var changeLikePhotoId: String?
    var changeLikeIsLike: Bool?
    var mockChangeLikeResult: Result<PhotoLikeResult, Error>?
    
    
    
    
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<ImageFeedz.PhotoLikeResult, Error>) -> Void) {
        changeLikeCalled = true
        changeLikePhotoId = photoId
        changeLikeIsLike = isLike
        if let result = mockChangeLikeResult {
                    completion(result)
                }
    }
   
         
    
   
      
    

    
}
