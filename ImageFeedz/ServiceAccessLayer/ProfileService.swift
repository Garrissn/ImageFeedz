//
//  ProfileService.swift
//  ImageFeedz
//
//  Created by Игорь Полунин on 10.05.2023.
//

import Foundation

final class ProfileService {
    
    static let shared = ProfileService()
    private let urlSession = URLSession.shared
    private var currentTask: URLSessionTask?
    private(set) var profile: Profile?

    
    
    func fetchProfile(_ token: String,
                      completion: @escaping (Result<Profile, Error>)-> Void) {

        assert(Thread.isMainThread)
        if currentTask != nil { currentTask?.cancel()}
        
        var request = profileRequest(token: token)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
        
            guard let self = self else { return }
            switch result {
            case .success(let profileResult):

                let name = (profileResult.firstName ?? " ") + " " + (profileResult.lastName ?? "")
                let userName = profileResult.userName
                let loginName =  "@" + profileResult.userName
                let bio = profileResult.bio ?? " "

                self.profile = Profile(username: userName,
                                      name: name,
                                      loginName: loginName,
                                       bio: bio)
                guard let  profile = self.profile else { return }

                    print(" удачный парсинг с токеном")
                completion(.success(profile))
            case .failure(let error):
                print("не удачный парсинг с токеном")
                completion(.failure(error))
            }
            self.currentTask = nil
        }
       // self.task = task
        task.resume()
    }

}

//extension ProfileService {
//    private func object (
//        for request: URLRequest,
//        completion: @escaping(Result<ProfileResult,Error>) -> Void) ->URLSessionTask {
//            let decoder = JSONDecoder()
//            return urlSession.data(for: request) { (result: Result<Data, Error>) in
//                switch result {
//                case .success(let data):
//                    do {
//                        let profileResult = try decoder.decode(ProfileResult.self, from: data)
//
//                        completion(.success(profileResult))
//                    } catch {
//                        completion(.failure(error))
//                        print("поймали ошибку в кейсе саксес")
//                    }
//                case .failure(let error):
//                    completion(.failure(error))
//                    print("ошибка в докодировании")
//
//                }
//            }
//        }
//}
private func profileRequest(token: String) -> URLRequest {
    URLRequest.makeHTTPRequest(path: "/me",
                               httpMethod: "GET",
                               baseURL: URL(string: "https://api.unsplash.com")!)
    
}
private func profileImageRequest(username: String) -> URLRequest {
    URLRequest.makeHTTPRequest(path: "/users/:\(username)",
                               httpMethod: "GET",
                               baseURL: URL(string: "https://api.unsplash.com")!)
    
}

struct ProfileResult: Decodable {
    let userName: String
    let firstName: String?
    let lastName: String?
    let bio: String?
   
    
    enum CodingKeys: String, CodingKey {
        case userName = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
      
    }
    
   
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String
}


