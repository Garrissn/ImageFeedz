//
//  ImagesListViewController.swift
//  ImageFeedz
//
//  Created by Игорь Полунин on 27.03.2023.
//


import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func blockingProgressHudShow()
    func blockingProgressHudHide()
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
   
    
    
    
    
    
    
    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Private Properties
    private var imageListPhotoServiceObserver: NSObjectProtocol?
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    var presenter: ImagesListPresenterProtocol?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        //presenter?.setupImageListServiceObserver()
        setupImageListServiceObserver ()
       // updateTableViewAnimated()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            let viewController = segue.destination as! SingleImageViewController
            let indexPath = sender as! IndexPath
            let photo = presenter?.photos[indexPath.row]
           // let photo = photos[indexPath.row]
            let image = photo?.largeImageURL
            guard let imageURL = URL(string: image ?? " " ) else { return }
            
             viewController.imageURL = imageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func blockingProgressHudHide() {
        UIBlockingProgressHUD.dismiss()
    }
    
    func blockingProgressHudShow() {
        UIBlockingProgressHUD.show()
    }
    
    
    
    private func setupImageListServiceObserver () {
        imageListPhotoServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.DidChangeNotification,
            object: nil,
            queue: .main)  { [weak self] _ in
            guard let self = self else { return }
        
            self.updateTableViewAnimated()
        }
        presenter?.fetchPhotosNextPage()
       // imagesListService.fetchPhotosNextPage()
        
    }
       func updateTableViewAnimated() {
        guard   let oldCount = presenter?.updateTableViewAnimated().oldCount,
                let newCount = presenter?.updateTableViewAnimated().newCount else { return }

           if oldCount != newCount {
               tableView.performBatchUpdates {
                   let indexPaths = (oldCount..<newCount).map { i in
                       IndexPath(row: i, section: 0)
                   }
                   tableView.insertRows(at: indexPaths, with: .automatic)
               } completion: {  _ in }
           }
       }
}
// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard  let photosCount = presenter?.photos.count else { return 0 }
        return photosCount  //photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell,with: indexPath)
        return imageListCell
    }
    
    
}
// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let image = presenter?.photos[indexPath.row] else { return 0}
        //let image = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView( _ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath ) {
     
        presenter?.willDisplay(indexPath: indexPath)

            
        
        
    }
}

extension ImagesListViewController {
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.delegate = self
        
        let url = presenter?.configureCell(indexPath: indexPath).url
        let formattedDate = presenter?.configureCell(indexPath: indexPath).formattedData
        

        
        let cache = ImageCache.default
        cache.diskStorage.config.expiration = .seconds(600)
        cache.memoryStorage.config.cleanInterval = 30
        cell.cellImage.kf.indicatorType = .activity
        
        cell.cellImage.kf.setImage(with: url, placeholder: UIImage(named: "Rectangle.jpeg")) {  [weak self] _ in
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        

                cell.labelData.text = formattedDate
            
           
        
        cell.setIsLiked(islike: presenter?.photos[indexPath.row].isLiked ?? false)
       
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) { // получили номер нажатой ячейки
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        presenter?.imageListCellDidTapLike(indexPath: indexPath, completion: { isLiked in
            DispatchQueue.main.async {
                cell.setIsLiked(islike: isLiked)
            }
        }
        )
    
    }
    
}
protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}
