//
//  ImagesListViewControllerSpy.swift
//  ImageFeedzTests
//
//  Created by Игорь Полунин on 10.06.2023.
//


import Foundation
@testable import ImageFeedz

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImageFeedz.ImagesListPresenterProtocol?
    
    var loadTable = false
    var blockShow = false
    var blockHide = false
    
    func blockingProgressHudShow() {
        blockShow = true
    }
    
    func blockingProgressHudHide() {
        blockHide = true
    }
    
    func loadTableView(oldCount: Int, newCount: Int) {
        loadTable = true
        
    }
    
    
}
