//
//  OAuth2Service.swift
//  ImageFeedz
//
//  Created by Игорь Полунин on 24.04.2023.
//

import Foundation

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    
    private let urlSession = URLSession.shared
    
    private (set) var authToken: String? {
        get {
            return OAuth2TokenStorage().token
        }
        set {
            OAuth2TokenStorage().token = newValue
        }
    }
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    
    func fetchOAuthToken(_ code: String,
                         completion: @escaping (Result<String, Error>) -> Void ) {
        
        assert(Thread.isMainThread)
        
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        
        let request = authTokenRequest(code: code)
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody,Error>) in
         
            guard let self = self else { return }
            switch result {
            case .success(let body):
                let authToken = body.accessToken
                self.authToken = authToken
                completion(.success(authToken))
            case .failure(let error):
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
}



private func authTokenRequest(code: String) -> URLRequest {
    URLRequest.makeHTTPRequest(
        path: "/oauth/token"
        + "?client_id=\(AccessKey)"
        + "&&client_secret=\(SecretKey)"
        + "&&redirect_uri=\(RedirectURI)"
        + "&&code=\(code)"
        + "&&grant_type=authorization_code",
        httpMethod: "POST",
        baseURL: URL(string: "https://unsplash.com")! //?
    )
}

// MARK: - HTTP Request

extension URLRequest {
    static func makeHTTPRequest(
        path: String,
        httpMethod: String,
        baseURL: URL = DefaultBaseURL ) -> URLRequest {
            var request  = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
            request.httpMethod = httpMethod
            return request
        }
}


// MARK: - Network Connection

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
   
    
    func objectTask<T: Decodable> (for request: URLRequest,
                                   completion: @escaping (Result<T,Error>) -> Void) -> URLSessionTask {
    let fulfillCompletionOnMainThread:(Result<T,Error>) -> Void = { result in
        DispatchQueue.main.async {
            completion(result)
        }
    }
    let task = dataTask(with: request, completionHandler: { data, response, error in
        if let data = data,
           let response = response,
           let statusCode = (response as? HTTPURLResponse)?.statusCode
        {
            if 200 ..< 300 ~= statusCode {
                do{
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(T.self, from: data)
                    fulfillCompletionOnMainThread(.success(result))}
                catch { fulfillCompletionOnMainThread( .failure(error))
                    print(" поймали ошибку в блое кэч")
                }
            } else {
                fulfillCompletionOnMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                print(" поймали ошибку 1")
                print(statusCode)
            }
        } else if let error = error {
            fulfillCompletionOnMainThread(.failure(NetworkError.urlRequestError(error)))
            print(" поймали ошибку 2")
        } else {
            print(" поймали ошибку 3")
            fulfillCompletionOnMainThread(.failure(NetworkError.urlSessionError))
        }
    }
    )
    task.resume()
    return task
}
}
