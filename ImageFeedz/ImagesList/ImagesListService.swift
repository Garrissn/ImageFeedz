//
//  ImagesListService.swift
//  ImageFeedz
//
//  Created by Игорь Полунин on 25.05.2023.
//

import Foundation
import UIKit

protocol ImagesListServiceProtocol: AnyObject {
    func fetchPhotosNextPage ()
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<PhotoLikeResult, Error>) -> Void)
    var photos: [Photo] { get  }
}

final class ImagesListService: ImagesListServiceProtocol {
    
    static let shared = ImagesListService()
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    // MARK: - Private Properties
    
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private var imagesListServiceObserver: NSObjectProtocol?
    private let networkLayer = NetworkLayer.shared
    private(set) var photo: Photo?
    
    
    // MARK: - Services
    
    func fetchPhotosNextPage (){
        assert(Thread.isMainThread)
        print(" вызвали фэчфото")
        guard task == nil else { return } // идет ли сейчас загрузка? или нужно создать новый запрос?
        
        let nextPage = (lastLoadedPage ?? 0) + 1 // какую страницу загружать?
        print(" счетчик некст пейдж\(nextPage)")
        var request = photosRequest(page: nextPage)
        if let token = OAuth2TokenStorage().token { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        self.task = networkLayer.objectTask(for: request) {[weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            
            self.task = nil  // Сброс текущей задачи после завершения
            switch result {
                
            case .success(let photoResults):
                let newPhotos = photoResults.map { photoResult -> Photo in
                    let id = photoResult.id
                    let size = CGSize(width: photoResult.width, height: photoResult.height)
                    let createdAt = photoResult.createdAt
                    let welcomeDescription = photoResult.description ?? " "
                    let thumbImageURL = photoResult.urls?.thumb ?? " "
                    let largeImageURL = photoResult.urls?.full ?? " "
                    let isLiked = photoResult.likedByUser
                    
                    return  Photo(id: id, size: size, createdAt: createdAt, welcomeDescription: welcomeDescription, thumbImageURL: thumbImageURL, largeImageURL: largeImageURL, isLiked: isLiked)
                }
                DispatchQueue.main.async {
                    
                    self.photos.append(contentsOf: newPhotos)
                    print(" получили экз фото т фото резалт")
                    NotificationCenter.default
                        .post(
                            name: ImagesListService.DidChangeNotification,
                            object: self,
                            userInfo: ["newphotos": self.photos])
                }
                self.lastLoadedPage = nextPage //сохранить номер последней скачанной страницы
            case .failure(let error):
                print("Error fetching photos: \(error)")
            }
        }
        
        task?.resume()
        
    }
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<PhotoLikeResult, Error>) -> Void) {
        assert(Thread.isMainThread)
        var  request: URLRequest?
        
        if isLike {
            request = unlikeRequest(photoId: photoId)
        } else {
            request = likeRequest(photoId: photoId)
        }
        
        guard var request = request else { return }
        if let token = OAuth2TokenStorage().token { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        
        let task = networkLayer.objectTask(for: request) { [weak self] (result: Result<PhotoLikeResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success (let photo):
                // Поиск индекса элемента
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    // Текущий элемент
                    let photo = self.photos[index]
                    // Копия элемента с инвертированным значением isLiked.
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked
                    )
                    // Заменяем элемент в массиве.
                    self.photos[index] = newPhoto
                    
                }
                completion(result)
            case .failure(let error):
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
}

// MARK: - HTTP Request

private func photosRequest(page: Int) -> URLRequest {
    print(" сделали реквест")
    return URLRequest.makeHTTPRequest(path: "/photos?"
                                      + "page=\(page)"
                                      + "&per_page=10",
                                      httpMethod: "GET",
                                      baseURL: URL(string: "https://api.unsplash.com")!)
}

private func likeRequest(photoId: String) -> URLRequest {
    print(" сделали лайк rреквест")
    return URLRequest.makeHTTPRequest(path: "/photos/\(photoId)/like",
                                      
                                      httpMethod: "POST",
                                      baseURL: URL(string: "https://api.unsplash.com")!)
    
}
private func unlikeRequest(photoId: String) -> URLRequest {
    print(" сделали дизлайк rреквест")
    return URLRequest.makeHTTPRequest(path:"/photos/\(photoId)/like",
                                      httpMethod: "DELETE",
                                      baseURL: URL(string: "https://api.unsplash.com")!)
    
}

// MARK: - Models

struct PhotoLikeResult: Decodable {
    let photo: PhotoResult
}

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let description: String?
    let likedByUser: Bool
    let urls: UrlsResult?
    
    enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case createdAt = "created_at"
        case description
        case urls
        case likedByUser = "liked_by_user"
    }
    
    struct UrlsResult: Decodable {
        let thumb: String?
        let full: String?
    }
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: String?
    let welcomeDescription: String?
    let thumbImageURL: String?
    let largeImageURL: String?
    let isLiked: Bool
}
