//
//  ImagesListViewController.swift
//  ImageFeedz
//
//  Created by Игорь Полунин on 27.03.2023.
//


import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Private Properties
    private var imageListPhotoServiceObserver: NSObjectProtocol?
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        setupImageListServiceObserver ()
        //imagesListService.fetchPhotosNextPage()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            let viewController = segue.destination as! SingleImageViewController
            let indexPath = sender as! IndexPath
            guard let image = UIImage(named:  photos[indexPath.row].thumbImageURL ?? "") else { return print(" Error")}
            viewController.image = image
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
                self.photos = self.imagesListService.photos
            self.updateTableViewAnimated()
        }
    }
       func updateTableViewAnimated() {
           let oldCount = photos.count
           let newCount = imagesListService.photos.count
           photos = imagesListService.photos
           if oldCount != newCount {
               tableView.performBatchUpdates {
                   let indexPaths = (oldCount..<newCount).map { i in
                       IndexPath(row: i, section: 0)
                   }
                   tableView.insertRows(at: indexPaths, with: .automatic)
               } completion: {[weak self] _ in
                   self?.imagesListService.fetchPhotosNextPage()
               }
           }
       }
}
// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
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
        
        
        guard let image = UIImage(named: photos[indexPath.row].thumbImageURL ?? " ") else {
            return 0
        }
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView( _ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAtindexPath: IndexPath ) {
        guard  let indexPath = tableView.indexPath(for: cell) else { return }
        print(" вызвали фэчфото0")
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
            print(" вызвали фэчфото1")
            //завершено скачивание отправить запрос на скачивание следующей
        }
        print(" вызвали фэчфото2")
    }
    
}

extension ImagesListViewController {
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
//        guard  let image = UIImage(named: photos[indexPath.row]) else {
//            return
//        }
        
        guard let photoImageURL = URL(string: photos[indexPath.row].thumbImageURL!)
              //let imageURL = URL(string: photoImageURL)
                                      else { return print(" ne udalos sdelat url v imageslistviewcontr")}
        
        let cache = ImageCache.default
        cache.diskStorage.config.expiration = .seconds(600)
        cache.memoryStorage.config.cleanInterval = 30
        cell.cellImage.kf.indicatorType = .activity
     
        cell.cellImage.kf.setImage(with: photoImageURL, placeholder: UIImage(named: "Rectangle.jpeg")) {  [weak self] _ in
            guard let self = self else { return }
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        //cell.cellImage.image = image
        cell.labelData.text = dateFormatter.string(from: Date())
        
        let isLiked = indexPath.row % 2 == 0
        let likedImage = isLiked ? UIImage(named: "likeOff") : UIImage(named: "likeOn")
        cell.likeButton.setImage(likedImage, for: .normal)
    }
}
