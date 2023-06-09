//
//  ProfileViewContrillerSpy.swift
//  ImageFeedzTests
//
//  Created by Игорь Полунин on 09.06.2023.
//

import Foundation
@testable import ImageFeedz

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ImageFeedz.ProfileViewPresenterProtocol?
    var updateAvatar: Bool = false
    var updateProfile: Bool = false
    
    func updateAvatar(with imageURL: URL) {
        updateAvatar = true
        
    }
    
    func updateProfileDetails(profile: ImageFeedz.Profile?) {
        updateProfile = true
        
    }
}

