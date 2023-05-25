//
//  ImagesListService.swift
//  ImageFeedz
//
//  Created by Игорь Полунин on 25.05.2023.
//

import Foundation
import UIKit

final class ImagesListService {
    
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private var perPage = 10
    
    private let networkLayer = NetworkLayer.shared
    private(set) var photo: Photo?
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    

    func tableView( _ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAtindexPath: IndexPath ) {
        guard  let indexPath = tableView.indexPathForSelectedRow else { return }
        if indexPath.row + 1 == photos.count {
            fetchPhotosNextPage()
            //завершено скачивание отправить запрос на скачивание следующей
           
        }
        
    }
    private func fetchPhotosNextPage (){
        assert(Thread.isMainThread)
        
        guard task == nil else { return } // идет ли сейчас загрузка? или нужно создать новый запрос?
        
        let nextPage = lastLoadedPage ?? 0 + 1 // какую страницу загружать?
        let request = photosRequest(page: nextPage, perPage: perPage)
        
        let task = networkLayer.objectTask(for: request) {[weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            
            self.task = nil  // Сброс текущей задачи после завершения
            switch result {
                
            case .success(let photoResult):
                let newPhotos = photoResult.map { photoResult -> Photo in
                    let id = photoResult.id
                    let size = CGSize(width: photoResult.width, height: photoResult.height)
                    let createdAt = photoResult.createdAt
                    let welcomeDescription = photoResult.description ?? " "
                    let thumbImageURL = photoResult.urls?.thumb ?? " "
                    let largeImageURL = photoResult.urls?.full ?? " "
                    let isLiked = photoResult.likedByUser ?? false
                    return Photo(id: id,
                                 size: size,
                                 createdAt: createdAt,
                                 welcomeDescription: welcomeDescription,
                                 thumbImageURL: thumbImageURL,
                                 largeImageURL: largeImageURL,
                                 isLiked: isLiked)
                }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)  // сохранить в var photos: [Photo] = []
                    
                    
                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.DidChangeNotification,
                            object: self,
                            userInfo: ["newphotos": newPhotos])
                }
                self.lastLoadedPage = nextPage //сохранить номер последней скачанной страницы
            case .failure(let error):
                print("Error fetching photos: \(error)")
            }
        }
       
        task.resume()
        
    }
}




private func photosRequest(page: Int, perPage: Int) -> URLRequest {
    URLRequest.makeHTTPRequest(path: "/photos?"
                               + "page =\(page)"
                               + "&&per_page=\(perPage)",
                               httpMethod: "GET",
                               baseURL: URL(string: "https://api.unsplash.com")!)
    
}

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: Date?
    let description: String?
    let likedByUser: Bool?
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
    let size: CGSize?
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String?
    let largeImageURL: String?
    let isLiked: Bool?
}
