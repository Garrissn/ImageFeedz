//
//  WebViewControlllerSpy.swift
//  ImageFeedzTests
//
//  Created by Игорь Полунин on 10.06.2023.
//

import Foundation
@testable import ImageFeedz

final class WebViewControlllerSpy: WebViewViewControllerProtocol {
    var presenter: ImageFeedz.WebViewPresenterProtocol?
    var loadRequestCalled: Bool = false
    
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
        
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        
    }
    
    
}
