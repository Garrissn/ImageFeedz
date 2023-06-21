//
//  ProfileViewController.swift
//  ImageFeedz
//
//  Created by Игорь Полунин on 04.04.2023.
//


import UIKit
import Kingfisher
import WebKit

 protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    func updateAvatar(with imageURL: URL)
    func updateProfileDetails(profile: Profile?)
    
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
     var presenter: ProfileViewPresenterProtocol?
    
    // MARK: - Private Properties
  
    private let avatarImage: UIImageView = {
        let image = UIImage(named: "avatar")
        let avatarImage = UIImageView(image: image)
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        return avatarImage
    }()
    
    private let logoutButton: UIButton = {
        let logoutButton = UIButton()
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.setImage(UIImage(named: "logoutButton"), for: UIControl.State())
        logoutButton.addTarget(self,
                               action: #selector(logoutButtonTapped),
                               for: .touchUpInside)
        return logoutButton
    }()
    
    private let nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = .YPWhite
        nameLabel.font = UIFont(name: "SF-Pro", size: 23)
        return nameLabel
    }()
    
    private let loginNameLabel: UILabel = {
        let loginNameLabel = UILabel()
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        loginNameLabel.text = "@ekaterina_nov"
        loginNameLabel.textColor = .YPGray
        loginNameLabel.font =  UIFont(name: "SF-Pro", size: 13)
        return loginNameLabel
    }()
    
    private let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "Hello, world"
        descriptionLabel.textColor = .YPWhite
        descriptionLabel.font = UIFont(name: "SF-Pro", size: 13)
        return descriptionLabel
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        layoutViews()
        presenter?.viewDidLoad()
        presenter?.setupPrifileImageObserver()
       
    }
    
    
    // MARK: -  Methods
    
     func updateAvatar (with imageURL: URL) {
        
        let cache = ImageCache.default
        cache.diskStorage.config.expiration = .seconds(600)
        cache.memoryStorage.config.cleanInterval = 30
        
        let processor = RoundCornerImageProcessor(cornerRadius: 61)
        
        avatarImage.kf.indicatorType = .activity
        avatarImage.kf.setImage(with: imageURL, placeholder: UIImage(named: "avatar.jpeg"),
                                options: [.processor(processor)])
    }
    
     func updateProfileDetails(profile: Profile?) {
        
        guard let profile = profile else { return }
        descriptionLabel.text = profile.bio
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
    }
    
    private func addViews () {
        view.addSubview(avatarImage)
        view.addSubview(logoutButton)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
    }
    
    private func layoutViews () {
        NSLayoutConstraint.activate([
            avatarImage.heightAnchor.constraint(equalToConstant: 70),
            avatarImage.widthAnchor.constraint(equalToConstant: 70),
            avatarImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
        NSLayoutConstraint.activate([
            logoutButton.heightAnchor.constraint(equalToConstant: 22),
            logoutButton.widthAnchor.constraint(equalToConstant: 20),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImage.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -26)
        ])
        NSLayoutConstraint.activate([
            nameLabel.heightAnchor.constraint(equalToConstant: 18),
            nameLabel.widthAnchor.constraint(equalToConstant: 235),
            nameLabel.topAnchor.constraint(equalTo: avatarImage.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor)
        ])
        NSLayoutConstraint.activate([
            
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])
        NSLayoutConstraint.activate([
            
            descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    @objc
    private func logoutButtonTapped() {
        presenter?.logoutButtonTapped(presentingViewController: self)
    }
}


