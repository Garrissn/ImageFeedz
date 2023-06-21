//
//  ImagesListCell.swift
//  ImageFeedz
//
//  Created by Игорь Полунин on 27.03.2023.
//


import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBAction private func likeButtonTapped() {
        delegate?.imageListCellDidTapLike(self)
    }
    @IBOutlet  weak var cellImage: UIImageView!
    @IBOutlet  weak var likeButton: UIButton!
    @IBOutlet  weak var labelData: UILabel!
    
    // MARK: - Public Properties
    
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // otmeniaem zagruzku
        cellImage.image = nil
        cellImage.kf.cancelDownloadTask()
    }
    
    func setIsLiked(islike: Bool) {
        if islike {
            likeButton.setImage(UIImage(named: "likeOn"), for: .normal)
            
        } else {
            likeButton.setImage(UIImage(named: "likeOff"), for: .normal)
        }
    }
}


