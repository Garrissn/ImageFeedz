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
    private(set) var profile: Profile?
    
    
    func fetchProfile(_ token: String,
                      completion: @escaping (Result<Profile, Error>)-> Void) {
        
        var request = profileRequest(token: token)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = object(for: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profileResult):
                let name = profileResult.firstName + " " + profileResult.lastName
                let userName = profileResult.userName
                let loginName =  "@" + profileResult.userName
                let bio = profileResult.bio
                
                self.profile = Profile(username: userName,
                                      name: name,
                                      loginName: loginName,
                                      bio: bio)
                guard let  profile = profile else { return }
                
                    print(" удачный парсинг с токеном")
                completion(.success(profile))
            case .failure(let error):
                print("не удачный парсинг с токеном")
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func fetchImageProfile(userName: String, completion: @escaping (Result<String,Error>) -> Void) {
        let request = profileImageRequest(username: userName)
        let task = object(for: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profileResult):
                print("  удачный парсинг фото")
                guard let image = profileResult.profileResultImageUrl?.large else { return print ("no photo")}
                completion(.success(image))
                           case .failure(let error):
                print("не удачный парсинг с фото")
                            completion(.failure(error))
            }
        }
        task.resume()
    }
}

extension ProfileService {
    private func object (
        for request: URLRequest,
        completion: @escaping(Result<ProfileResult,Error>) -> Void) ->URLSessionTask {
            let decoder = JSONDecoder()
            return urlSession.data(for: request) { (result: Result<Data, Error>) in
                switch result {
                case .success(let data):
                    do {
                        let profileResult = try decoder.decode(ProfileResult.self, from: data)
                        completion(.success(profileResult))
                    } catch {
                        completion(.failure(error))
                        print("поймали ошибку в кейсе саксес")
                    }
                case .failure(let error):
                    completion(.failure(error))
                    print("ошибка в докодировании")
                    
                }
            }
        }
}
private func profileRequest(token: String) -> URLRequest {
    URLRequest.makeHTTPRequest(path: "/me",
                               httpMethod: "GET",
                               baseURL: URL(string: "https://unsplash.com")!)
    
}
private func profileImageRequest(username: String) -> URLRequest {
    URLRequest.makeHTTPRequest(path: "/users/:username",
                               httpMethod: "GET",
                               baseURL: URL(string: "https://unsplash.com")!)
    
}

struct ProfileResult: Decodable {
    let userName: String
    let firstName: String
    let lastName: String
    let bio: String
    let profileResultImageUrl: ProfileResultImageUrl?
    
    enum CodingKeys: String, CodingKey {
        case userName = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
        case profileResultImageUrl = "profile_image"
    }
    
   
}
struct ProfileResultImageUrl: Decodable {
    let small: String
    let medium: String
    let large: String
}
struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String
}


