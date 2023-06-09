//
//  TabBarController.swift
//  ImageFeedz
//
//  Created by Игорь Полунин on 20.05.2023.
//


import UIKit

final class TabBarController: UITabBarController {
    
    override func awakeFromNib() {
        super .awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        guard   let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController else { return print(" не удалось создать вьюконтр в таббаре")}
     
        let imagesListService = ImagesListService.shared
        let  imagesListPresenter = ImagesListPresenter(imagesListService: imagesListService, view: imagesListViewController)
        
        imagesListViewController.presenter = imagesListPresenter
        
        
        let profileViewController = ProfileViewController()
        
        let profileService = ProfileService.shared
        let profileImageService = ProfileImageService.shared
    let tokenStorage = OAuth2TokenStorage()
        let profileViewPresenter = ProfileViewPresenter(view: profileViewController, profileService: profileService, profileImageService: profileImageService, tokenStorage: tokenStorage)
        profileViewController.presenter = profileViewPresenter
        profileViewPresenter.view = profileViewController
        
        profileViewController.tabBarItem = UITabBarItem(title: nil,
                                                        image: UIImage(named: "tab_profile_active"),
                                                        selectedImage: nil)
        
        self.viewControllers = [imagesListViewController, profileViewController ]
    }
}
