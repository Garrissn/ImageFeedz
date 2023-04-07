//
//  SingleImageViewController.swift
//  ImageFeedz
//
//  Created by Игорь Полунин on 06.04.2023.
//

import Foundation
import UIKit


final class SingleImageViewController: UIViewController {
    var image: UIImage! {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }
    
    @IBOutlet  weak var imageView: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBAction func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
            super.viewDidLoad()
            imageView.image = image
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
