//
//  ImagesListCell.swift
//  ImageFeedz
//
//  Created by Игорь Полунин on 27.03.2023.
//

import Foundation
import UIKit

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet  weak var cellImage: UIImageView!
    @IBOutlet  weak var likeButton: UIButton!
    @IBOutlet  weak var labelData: UILabel!
    // MARK: - Public Properties
    static let reuseIdentifier = "ImagesListCell"
    
    
}
