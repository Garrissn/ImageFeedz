//
//  SingleImageViewController.swift
//  ImageFeedz
//
//  Created by Игорь Полунин on 06.04.2023.
//


import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    
    // MARK: -  Properties
   
    var imageURL: URL! {
        didSet {
            guard isViewLoaded else { return }
            setLargeImage()
        }
    }
    
    // MARK: - Oulets
   
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    @IBAction private func didTapShareButton() {
        let share = UIActivityViewController(activityItems: [imageView.image as Any], applicationActivities: nil)
        present(share, animated: true, completion: nil)
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLargeImage()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }
    
    // MARK: - Private Methods
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    private func showError () {
        let alertController = UIAlertController(title: "Что-то пошло не так", message: "Попробовать ещё раз?", preferredStyle: .alert)
        let againAction = UIAlertAction(title: "Повторить?", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.setLargeImage()
        }
        let nenadoAction = UIAlertAction(title: "Не надо", style: .default, handler: nil)
        alertController.addAction(againAction)
        alertController.addAction(nenadoAction)
        present(alertController, animated: true)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
extension SingleImageViewController {
    private func setLargeImage() {
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: imageURL) {[weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                self.showError()
            }
        }
        
    }
}
