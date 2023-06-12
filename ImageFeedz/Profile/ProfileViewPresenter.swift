//
//  ProfileViewPresenter.swift
//  ImageFeedz
//
//  Created by Игорь Полунин on 04.06.2023.
//

import Foundation
import UIKit

protocol ProfileViewPresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func logoutButtonTapped(presentingViewController: UIViewController)
    func setupPrifileImageObserver()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    // MARK: -  Properties
    private var profileImageServiceObserver: NSObjectProtocol?
    weak  var view: ProfileViewControllerProtocol?
    private let profileService: ProfileServiceProtocol
    private let profileImageService : ProfileImageServiceProtocol
    private let tokenStorage: OAuth2TokenStorageProtocol
    
    init(view: ProfileViewControllerProtocol? ,
         profileService: ProfileServiceProtocol,
         profileImageService: ProfileImageServiceProtocol,
         tokenStorage: OAuth2TokenStorageProtocol) {
        self.view = view
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.tokenStorage = tokenStorage
    }
    
    // MARK: -  Metods
    
    func viewDidLoad() {
        
        guard let profileImageURL = profileImageService.avatarURL,
              let imageURL = URL(string: profileImageURL) else { return }
        view?.updateAvatar(with: imageURL)
        
        guard let profile = profileService.profile else { return }
        view?.updateProfileDetails(profile: profile)
    }
    
    func setupPrifileImageObserver() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.DidChangeNotification,
            object: nil,
            queue: .main)  { [weak self] _ in
                guard let self = self else { return }
                self.viewDidLoad()
            }
    }
    
    
    func logoutButtonTapped(presentingViewController: UIViewController) {
        let alertController = UIAlertController(title: "Пока,пока!", message: "Уверены что хотите выйти ?", preferredStyle: .alert)
        let logoutAction = UIAlertAction(title: "Да", style: .default)  { [weak self] _ in
            guard let self = self else { return }
            self.tokenStorage.cleanToken()
            WebViewViewController.clean()
            guard let window = UIApplication.shared.windows.first else {
                fatalError("Invalid Configuration")
            }
            let splashViewController = SplashViewController()
            window.rootViewController = splashViewController
            window.makeKeyAndVisible()
            
        }
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel, handler: nil)
        alertController.addAction(logoutAction)
        alertController.addAction(cancelAction)
        presentingViewController.present(alertController,animated: true, completion: nil)
        print("logoutButtonTapped")
    }
}
