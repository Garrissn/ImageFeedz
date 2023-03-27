//
//  ImagesListCell.swift
//  ImageFeedz
//
//  Created by Игорь Полунин on 27.03.2023.
//

import Foundation
import UIKit

final class ImagesListCell: UITableViewCell {
    
    
    
    @IBOutlet weak var cellImage: UIImageView!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var labelData: UILabel!
    
    static let reuseIdentifier = "ImagesListCell"
    
    
}
