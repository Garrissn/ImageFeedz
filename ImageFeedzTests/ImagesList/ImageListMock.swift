//
//  ImageListMock.swift
//  ImageFeedzTests
//
//  Created by Игорь Полунин on 10.06.2023.
//



import Foundation
@testable import ImageFeedz

final class  ImagesListMock: ImagesListServiceProtocol {
    func fetchPhotosNextPage() {
        
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<ImageFeedz.PhotoLikeResult, Error>) -> Void) {
        
    }
    
    var photos: [ImageFeedz.Photo]
    
    var photo = Photo(id: <#T##String#>, size: <#T##CGSize#>, createdAt: <#T##String?#>, welcomeDescription: <#T##String?#>, thumbImageURL: <#T##String?#>, largeImageURL: <#T##String?#>, isLiked: <#T##Bool#>)
    
}
