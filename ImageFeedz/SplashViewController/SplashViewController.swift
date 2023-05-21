//
//  SplashViewController.swift
//  ImageFeedz
//
//  Created by Игорь Полунин on 27.04.2023.
//


import UIKit
import ProgressHUD
import Kingfisher

final class SplashViewController: UIViewController {
    
    
    
    
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let oauth2Service = OAuth2Service()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = oauth2TokenStorage.token {
            self.fetchProfile(token: token)
            switchToTabBarController()
            
        } else {
            performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
  
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
      //  let storyBoard = UIStoryboard(name: "Main", bundle: .main)
        
        //let splashViewController = storyBoard.instantiateViewController(identifier: "SplashViewController")
       let splashViewController = SplashViewController()
        
        
    }
    
    
    
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(identifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
            guard let navigationController = segue.destination as? UINavigationController,
                  let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for\(ShowAuthenticationScreenSegueIdentifier)") }
            viewController.delegate = self
            // delegate
        }
            else { super.prepare(for: segue, sender: sender) }
        }
    }

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        
        dismiss(animated: true) {[weak self] in
            guard let self = self else { return }
            UIBlockingProgressHUD.show()
            self.fetchOAuthToken(code)
        }
    }
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.fetchProfile(token: token)
                
            case .failure:
                
                UIBlockingProgressHUD.dismiss()
                self.showErrorAlert()
                print("Error") //TODO показатьт ошибку
                break
            }
        }
    }
    
    private func showErrorAlert () {
        let alertController = UIAlertController(title: "Что-то пошло не так(", message: "Не удалось войти в систему", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil)
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func fetchProfile(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                
            
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                //let username = profile.username
                self.profileImageService.fetchProfileImageURL(username: profile.username) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success:
                        // обработка успешного ывполнения
                        print(" успешное выполнение запроса аватарки")
                        
                        self.switchToTabBarController()
                    case.failure(let error):
                        
                        print("Error fetching profile image URL: \(error)")
                        break
                    }
                    
                }
                UIBlockingProgressHUD.dismiss()
                self.switchToTabBarController()
                
            case .failure:
                // TODO показать ошибку
                
                UIBlockingProgressHUD.dismiss()
                self.showErrorAlert()
                break
            }
        }
        }
    }
    
}



