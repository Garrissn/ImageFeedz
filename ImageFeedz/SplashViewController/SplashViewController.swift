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
    
    // MARK: - Constants
    
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    // MARK: - Services
    
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let oauth2Service = OAuth2Service()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    // MARK: - Views
    
    private let splashScreenImage: UIImageView = {
        let image = UIImage(named: "splash_screen_logo")
        let splashScreenImage = UIImageView(image: image)
        splashScreenImage.translatesAutoresizingMaskIntoConstraints = false
        return splashScreenImage
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(splashScreenImage)
        view.backgroundColor = .YPBlack
        setupSplashScreenLogo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if oauth2TokenStorage.token != nil { guard let token = oauth2TokenStorage.token else { return }
            fetchProfile(token: token)
        } else {
            self.presentAuthViewController()
            print(" токена нет  переход ауфконтр")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Private Methods
    
    private func setupSplashScreenLogo() {
        NSLayoutConstraint.activate([
            splashScreenImage.heightAnchor.constraint(equalToConstant: 77),
            splashScreenImage.widthAnchor.constraint(equalToConstant: 75),
            splashScreenImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            splashScreenImage.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func presentAuthViewController() {
        let storyBoard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyBoard.instantiateViewController(identifier: "AuthViewController") as? AuthViewController else { fatalError(" не удалось сделать окз ауфконтроллера") }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
        
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

// MARK: - AuthViewControllerDelegate

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
                print("new token")
            case .failure:
                UIBlockingProgressHUD.dismiss()
                self.showErrorAlert()
                print("Error")
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
                    guard let username = profile.username else { return print(" не удалось получить юзернейм")}
                    self.profileImageService.fetchProfileImageURL(username: username) { [weak self] result in
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
                    UIBlockingProgressHUD.dismiss()
                    self.showErrorAlert()
                    break
                }
            }
        }
    }
    
}



