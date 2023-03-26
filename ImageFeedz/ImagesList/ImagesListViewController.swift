//
//  ViewController.swift
//  ImageFeedz
//
//  Created by Игорь Полунин on 24.03.2023.
//

import UIKit

class ImagesListViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    override func viewDidLoad() {
        
        print("fdkjkdkjf")
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    private func configCell(for cell: ImageslistCell) {
        
    }
    
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageslistCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImageslistCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell)
        return imageListCell
    }
}
extension ImagesListViewController: UITableViewDelegate {
    
}
