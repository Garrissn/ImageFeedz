//
//  ProfileImageService.swift
//  ImageFeedz
//
//  Created by Игорь Полунин on 17.05.2023.
//

import Foundation
protocol ProfileImageServiceProtocol {
    var avatarURL: String? { get }
}
final class ProfileImageService: ProfileImageServiceProtocol {
    // MARK: - Constants
    
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared =  ProfileImageService()
    
    // MARK: - Private Properties
    
    private (set) var avatarURL: String?
    private let networkLayer = NetworkLayer.shared
    private var currentTask: URLSessionTask?
    
    // MARK: - Services
    
    func fetchProfileImageURL(username: String, _ complition: @escaping(Result<String,Error> ) -> Void) {
        assert(Thread.isMainThread)
        if currentTask != nil {currentTask?.cancel() }
        var request = profileImageRequest(username: username)
        if let token = OAuth2TokenStorage().token { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        let task = networkLayer.objectTask(for: request) {[weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let userResult):
                guard  let avatarURL = userResult.profileResultImageUrl?.medium else { return  avatarURL = " "}
                self.avatarURL = avatarURL
                print(" est avatar")
                complition(.success(avatarURL))
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.DidChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL])
            case .failure(let error):
                print("net avatar")
                complition(.failure(error))
            }
            self.currentTask = nil
        }
        self.currentTask = task
        task.resume()
    }
}

// MARK: - Request

private func profileImageRequest(username: String) -> URLRequest {
    URLRequest.makeHTTPRequest(path: "/users/\(username)",
                               httpMethod: "GET",
                               baseURL: URL(string: "https://api.unsplash.com")!)
}

// MARK: - Models

struct UserResult: Decodable {
    let profileResultImageUrl: ProfileResultImageUrl?
    
    enum CodingKeys: String, CodingKey {
        case profileResultImageUrl = "profile_image"
    }
}
struct ProfileResultImageUrl: Decodable {
    let medium: String?
}
