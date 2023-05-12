//
//  WebViewViewController.swift
//  ImageFeedz
//
//  Created by Игорь Полунин on 20.04.2023.
//

import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}


final class WebViewViewController: UIViewController {
    
    fileprivate let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    
    
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var webView: WKWebView!
    
     weak var delegate: WebViewViewControllerDelegate?
  
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         loadWebView()
         webView.navigationDelegate = self
    }
    
    @IBAction private func didTapBackButton(_ sender: Any?) {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        webView.addObserver(self,
                            forKeyPath: #keyPath(WKWebView.estimatedProgress),
                            options: .new,
                            context: nil)
        updateProgress()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
    }
    
   
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
}
 
extension WebViewViewController: WKNavigationDelegate { // пришел ответ из ансплеш в виде УРЛ, проверяем адрес , делаем выборку ищем код авторизации и передаем его в вебвью
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url,
           let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code"})
        {
            return codeItem.value
        } else {
            return nil
        }
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

private extension WebViewViewController { // собрали юрл реквест для загрузки вебконтента и передали во вьюдидлоад
    func loadWebView() {
        var urlComponents = URLComponents(string: UnsplashAuthorizeURLString)!
        urlComponents.queryItems = [
           URLQueryItem(name: "client_id", value: AccessKey),
           URLQueryItem(name: "redirect_uri", value: RedirectURI),
           URLQueryItem(name: "response_type", value: "code"),
           URLQueryItem(name: "scope", value: AccessScope)
         ]
        guard let url = urlComponents.url else { return print ("не удалось получить урл")}
        
         let request = URLRequest(url: url)
         webView.load(request)
    }
}



