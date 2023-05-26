//
//  NetworkLayer.swift
//  ImageFeedz
//
//  Created by Игорь Полунин on 23.05.2023.
//

import Foundation

final class NetworkLayer {
    
    static let shared = NetworkLayer()
    private let urlSession = URLSession.shared
    
    func objectTask<T: Decodable> (for request: URLRequest,
                                   completion: @escaping (Result<T,Error>) -> Void) -> URLSessionTask {
        return urlSession.data(for: request) { result in
            
            switch result {
            case .success(let data):
                do{
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(T.self, from: data)
                    completion(.success(result))
                    
                }
                catch { completion( .failure(error))
                    print(" поймали ошибку в блое кэч")
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Network Connection

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func data(for request: URLRequest,
                                   completion: @escaping (Result<Data,Error>) -> Void) -> URLSessionTask {
        let fulfillCompletionOnMainThread:(Result<Data,Error>) -> Void = { result in
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
                    fulfillCompletionOnMainThread(.success(data))
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
        
        return task
    }
}
