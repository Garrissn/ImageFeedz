//
//  ProfileImageService.swift
//  ImageFeedz
//
//  Created by Игорь Полунин on 17.05.2023.
//

import Foundation

final class ProfileImageService {
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared =  ProfileImageService()
    
    private (set) var avatarURL: String?
    private let urlSession = URLSession.shared
    private var currentTask: URLSessionTask?
    
    func fetchProfileImageURL(username: String, _ complition: @escaping(Result<String,Error> ) -> Void) {
        assert(Thread.isMainThread)
        if currentTask != nil {currentTask?.cancel() }
        
        
        var request = profileImageRequest(username: username)
        if let token = OAuth2TokenStorage().token { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        let task = urlSession.objectTask(for: request) {[weak self] (result: Result<UserResult, Error>) in
         
            guard let self = self else { return }
            
            switch result {
            case .success(let userResult):
                guard  let avatarURL = userResult.profileResultImageUrl?.small else { return  avatarURL = " "}
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


private func profileImageRequest(username: String) -> URLRequest {
    URLRequest.makeHTTPRequest(path: "/users/\(username)",
                               httpMethod: "GET",
                               baseURL: URL(string: "https://api.unsplash.com")!)
}

struct UserResult: Decodable {
    let profileResultImageUrl: ProfileResultImageUrl?
    
    enum CodingKeys: String, CodingKey {
        case profileResultImageUrl = "profile_image"
    }
}
struct ProfileResultImageUrl: Decodable {
    let small: String?
}
