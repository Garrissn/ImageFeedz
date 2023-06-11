//
//  ImagesListPresenter.swift
//  ImageFeedz
//
//  Created by Игорь Полунин on 08.06.2023.
//

import Foundation
protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func fetchPhotosNextPage()
    var photos: [Photo] { get set }
    func willDisplay( indexPath: IndexPath)
    func configureCell(indexPath: IndexPath) -> (url: URL, formattedData: String)
    func imageListCellDidTapLike(indexPath: IndexPath, completion: @escaping (Bool) -> Void)
    func setupImageListServiceObserver ()
    
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    
    private var imageListPhotoServiceObserver: NSObjectProtocol?
    internal var photos: [Photo] = []
    weak var view: ImagesListViewControllerProtocol?
    
    private var imagesListService: ImagesListServiceProtocol
    
    init(imagesListService: ImagesListServiceProtocol, view: ImagesListViewControllerProtocol ) {
        self.imagesListService = imagesListService
        self.view = view
    }
    
    
    private lazy var isoDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        return formatter
    }()
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
    
    
    
    
    func viewDidLoad() {
        
        setupImageListServiceObserver()
        
    }
    
    func fetchPhotosNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func setupImageListServiceObserver() {
        imageListPhotoServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.DidChangeNotification,
            object: nil,
            queue: .main)  { [weak self] _ in
                guard let self = self else { return }
                
                self.updateTableViewAnimated()
            }
        imagesListService.fetchPhotosNextPage()
        
    }
    
    
    func updateTableViewAnimated()  {
        let oldCount = photos.count
        print(" счетчик начальный \(oldCount)")
        let newCount = imagesListService.photos.count
        
        photos = imagesListService.photos
        print(" счетчик новый после присвоения  \(newCount)")
        
        print(" счетчик новый после присвоения2  \(photos.count)")
        view?.loadTableView(oldCount: oldCount, newCount: newCount)
    }
    
    
    
    
    func willDisplay(indexPath: IndexPath) {
        if indexPath.row + 1 == imagesListService.photos.count {
            imagesListService.fetchPhotosNextPage()
            print(" вызвали фэчфото1")
        }
    }
    
    func configureCell(indexPath: IndexPath) -> (url: URL, formattedData: String) {
        let image = photos[indexPath.row]
        guard  let thumbUrlString = image.thumbImageURL,
               let url = URL(string: thumbUrlString) else { fatalError(" invalid url") }
        
        guard  let createdAt = image.createdAt,
               let date = isoDateFormatter.date(from: createdAt) else { fatalError("Invalid date")}
        
        
        let formattedDate = dateFormatter.string(from: date)
     
        
        return (url, formattedDate)
    }
    
    
    func imageListCellDidTapLike(indexPath: IndexPath, completion: @escaping (Bool) -> Void){
        let photo = photos[indexPath.row] // по номеру ячейуи нашли номер фото в массиве и передали в вызов сервиса по смене лайка
        view?.blockingProgressHudShow()
        imagesListService.changeLike(photoId: photo.id, isLike: photo.isLiked) { result in
            
            switch result {
            case .success(let photoResult):
                
                self.photos = self.imagesListService.photos
                let isLike = self.photos[indexPath.row].isLiked
                
                completion (isLike)
            case .failure:
                print(" alertcontr")
                completion(false)
            }
            self.view?.blockingProgressHudHide()
            
        }
    }
    
}

