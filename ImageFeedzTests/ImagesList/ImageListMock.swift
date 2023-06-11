//
//  ImageListMock.swift
//  ImageFeedzTests
//
//  Created by Игорь Полунин on 10.06.2023.
//



import Foundation
@testable import ImageFeedz

final class  ImagesListServiceMock: ImagesListServiceProtocol {
    
    var fetchPhotosNextPageCalled = false
    var photos: [Photo] = []
    
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<ImageFeedz.PhotoLikeResult, Error>) -> Void) {
        
    }
   
            
           
      
    

    
}
