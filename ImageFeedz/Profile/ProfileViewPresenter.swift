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
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    
    
    var view: ProfileViewControllerProtocol?
    private let profileService = ProfileService.shared
    private let tokenStorage = OAuth2TokenStorage()
    
    func viewDidLoad() {
        
        guard let profileImageURL = ProfileImageService.shared.avatarURL,
              let imageURL = URL(string: profileImageURL) else { return }
        
        view?.updateAvatar(with: imageURL)
        
        guard let profile = profileService.profile else { return }
        
        view?.updateProfileDetails(profile: profile)
    }
    
    
    
    
    func logoutButtonTapped(presentingViewController: UIViewController) {
        let alertController = UIAlertController(title: "Пока,пока!", message: "Уверены что хотите выйти ?", preferredStyle: .alert)
        let logoutAction = UIAlertAction(title: "Да", style: .default)  { _ in
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
