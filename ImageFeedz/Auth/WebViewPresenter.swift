//
//  WebViewPresenter.swift
//  ImageFeedz
//
//  Created by Игорь Полунин on 02.06.2023.
//

import Foundation
import WebKit



public protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}


final class WebViewPresenter: WebViewPresenterProtocol {
    
    var authHelper: AuthHelperProtocol
    weak var view: WebViewViewControllerProtocol?
    
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    
    func viewDidLoad() {
        
        let request = authHelper.authRequest()
        view?.load(request: request)
        didUpdateProgressValue(0)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress( for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
    
    
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
    
}

