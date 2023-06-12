//
//  WebViewViewController.swift
//  ImageFeedz
//
//  Created by Игорь Полунин on 20.04.2023.
//

import UIKit
import WebKit


public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

final class WebViewViewController: UIViewController, WebViewViewControllerProtocol {
    
    // MARK: -  Properties
    
    var presenter: WebViewPresenterProtocol?
    private var estimatedProgressObservation: NSKeyValueObservation?
    weak var delegate: WebViewViewControllerDelegate?
    
    // MARK: -  Outlets
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var webView: WKWebView!
    @IBAction private func didTapBackButton(_ sender: Any?) {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        webView.navigationDelegate = self
        estimatedProgressObservation = webView.observe(\.estimatedProgress,
                                                        options: [],
                                                        changeHandler: { [weak self] _, _ in
            guard let self = self else { return }
            presenter?.didUpdateProgressValue(webView.estimatedProgress)
        })
    }
    // MARK: - Methods
    
    private func observe<Root,Value>(
        _ keyPath: KeyPath<Root,Value>,
        options: NSKeyValueObservingOptions = [],
        changeHandler: @escaping (Root, NSKeyValueObservedChange<Value>) -> Void
        
    ) -> NSKeyValueObservation {
        return observe(keyPath, options: options, changeHandler: changeHandler)
        
    }
    
    func load(request: URLRequest) {
        webView.load(request)
    }
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
    
    
}

extension WebViewViewController: WKNavigationDelegate { // пришел ответ из ансплеш в виде УРЛ, проверяем адрес , делаем выборку ищем код авторизации и передаем его в вебвью
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            
            return  presenter?.code(from: url)
        }
        return nil
    }
    
    func webView(_ webView: WKWebView,//реализация протокола WKNavigationDelegate
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = code(from: navigationAction) {
            
            delegate?.webViewViewController(self, didAuthenticateWithCode: code) // делегируем обработку кода авторизации в AuthViewController метод webViewViewController
            
            decisionHandler(.cancel)  // код авторизации получен
        } else {
            decisionHandler(.allow)
        }
    }
    
}

extension WebViewViewController {
    static func clean() {
        // Очищаем все куки из хранилища.
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
