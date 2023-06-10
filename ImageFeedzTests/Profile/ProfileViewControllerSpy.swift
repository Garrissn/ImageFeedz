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
    
    
    
    var updateAvatarImage: Bool = false
    var updateProfile: Bool = false
    
    func updateAvatar(with imageURL: URL) {
        updateAvatarImage = true
        
    }
    
    func updateProfileDetails(profile: Profile?) {
        updateProfile = true
        
    }
}

