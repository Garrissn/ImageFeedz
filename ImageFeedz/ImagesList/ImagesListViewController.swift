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
    func blockingProgressHudHide() {
        UIBlockingProgressHUD.dismiss()
    }
    
    func blockingProgressHudShow() {
        UIBlockingProgressHUD.show()
    }
    
    var presenter: ImagesListPresenterProtocol?
    
    
    
    
    
    
    
    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Private Properties
    private var imageListPhotoServiceObserver: NSObjectProtocol?
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
  
    
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
//           let oldCount = photos.count
//           print(" счетчик начальный \(oldCount)")
//           let newCount = imagesListService.photos.count
//           print(" счетчик новый после присвоения  \(newCount)")
//           photos = imagesListService.photos
//           print(" счетчик новый после присвоения2  \(photos.count)")
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
//
//        if indexPath.row + 1 == imagesListService.photos.count {
//            imagesListService.fetchPhotosNextPage()
//            print(" вызвали фэчфото1")
            
        
        
    }
}

extension ImagesListViewController {
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.delegate = self
        
        let url = presenter?.configureCell(indexPath: indexPath).url
        let formattedDate = presenter?.configureCell(indexPath: indexPath).formattedData
        
//        let image = photos[indexPath.row]
//        guard let thumbUrlString = image.thumbImageURL,
//              let url = URL(string: thumbUrlString) else { return }
        
        let cache = ImageCache.default
        cache.diskStorage.config.expiration = .seconds(600)
        cache.memoryStorage.config.cleanInterval = 30
        cell.cellImage.kf.indicatorType = .activity
        
        cell.cellImage.kf.setImage(with: url, placeholder: UIImage(named: "Rectangle.jpeg")) {  [weak self] _ in
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
//        if let createdAt = image.createdAt,
//           let date = isoDateFormatter.date(from: createdAt) {
//
//                let formattedDate = dateFormatter.string(from: date)
                cell.labelData.text = formattedDate
            
           // } else { cell.labelData.text = " Error date"}
        
        cell.setIsLiked(islike: presenter?.photos[indexPath.row].isLiked ?? false)
        //let likedImage =  UIImage(named: "likeOff")
        //cell.likeButton.setImage(likedImage, for: .normal)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) { // получили номер нажатой ячейки
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        presenter?.imageListCellDidTapLike(indexPath: indexPath, completion: { isLiked in
            DispatchQueue.main.async {
                cell.setIsLiked(islike: isLiked)
            }
        })
        
//        let photo = photos[indexPath.row] // по номеру ячейуи нашли номер фото в массиве и передали в вызов сервиса по смене лайка
//        UIBlockingProgressHUD.show()
//        imagesListService.changeLike(photoId: photo.id, isLike: photo.isLiked) { result in
//
//            switch result {
//            case .success(let photoResult):
//
//                self.photos = self.imagesListService.photos
//                cell.setIsLiked(islike: self.photos[indexPath.row].isLiked)
//
//            case .failure:
//                print(" alertcontr")
//            }
//            UIBlockingProgressHUD.dismiss()
//
//        }
    }
    
    
}
protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}
