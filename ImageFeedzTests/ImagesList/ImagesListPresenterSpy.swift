//
//  ImagesListPresenterSpy.swift
//  ImageFeedzTests
//
//  Created by Игорь Полунин on 10.06.2023.
//

import Foundation
@testable import ImageFeedz

final class  ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var photos: [ImageFeedz.Photo] = []
    
    var view: ImageFeedz.ImagesListViewControllerProtocol?
    let url = URL(string: "https://api.unsplash.com")!
    let formattedData = " Data"
    var setupImageList = false
    
    func viewDidLoad() {
        
    }
    
    func fetchPhotosNextPage() {
        
    }
    
    func willDisplay(indexPath: IndexPath) {
        
    }
    
    func configureCell(indexPath: IndexPath) -> (url: URL, formattedData: String) {
        return (url,formattedData)
    }
    
    func imageListCellDidTapLike(indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        
    }
    
    func setupImageListServiceObserver() {
        setupImageList = true
    }
    
    
}
