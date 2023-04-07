//
//  ProfileViewController.swift
//  ImageFeedz
//
//  Created by Игорь Полунин on 04.04.2023.
//

import Foundation
import UIKit

final class ProfileViewController: UIViewController {
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    
    @IBOutlet private weak var nameLabel: UILabel!
    
    @IBOutlet private weak var loginNameLabel: UILabel!
    
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    @IBOutlet private weak var logoutButton: UIButton!
    
    @IBAction func didTapLogoutButton() {
    }
    
    
    
}
