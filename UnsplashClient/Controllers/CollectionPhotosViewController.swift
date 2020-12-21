//
//  CollectionPhotosViewController.swift
//  UnsplashClient
//
//  Created by Максим Голов on 20.12.2020.
//

import UIKit
import TUSafariActivity
import ARChromeActivity

// MARK: CollectionPhotosViewController

class CollectionPhotosViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Segue properties
    
    var collection: PhotoCollection!

    // MARK: - Private Properties
    
    private let queryService = QueryService()
    private var images = [Image]()
    private var imagesCache: ImagesCache!
    private var currentPage = 1
    private var totalPages = 0
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = titleViewWith(title: collection.title, subtitle: collection.user.name)
        totalPages = Int((Double(collection.totalPhotos) / Double(QueryService.pageSize)).rounded(.up))
        
        queryService.getCollectionPhotos(collectionId: collection.id) { [weak self] newImages in
            guard let newImages = newImages else { return }
            self?.images = newImages
            self?.imagesCache = ImagesCache(size: newImages.count)
            self?.tableView.reloadData()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        navigationItem.titleView = titleViewWith(title: collection.title, subtitle: collection.user.name)
    }
    
    // MARK: - IBActions
    
    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        let activityViewController = UIActivityViewController(
                activityItems: [URL(string: collection.links.html)!],
                applicationActivities: [TUSafariActivity(), ARChromeActivity()])
        present(activityViewController, animated: true)
    }
    
    // MARK: - Private Functions
    
    func titleViewWith(title: String, subtitle: String) -> UIView {
        let maxWidth = UIScreen.main.bounds.width - 100
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -2, width: 0, height: 0))
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.text = title
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(x: 0, y: -2,
                                     width: min(maxWidth, titleLabel.frame.width),
                                     height: titleLabel.frame.height)

        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 18, width: 0, height: 0))
        subtitleLabel.backgroundColor = .clear
        subtitleLabel.textColor = .lightGray
        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()
        subtitleLabel.frame = CGRect(x: 0, y: 18,
                                     width: min(maxWidth, subtitleLabel.frame.width),
                                     height: subtitleLabel.frame.height)

        let titleView = UIView(frame: CGRect(x: 0, y: 0,
                                             width: max(titleLabel.frame.size.width, subtitleLabel.frame.size.width),
                                             height: 30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)

        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width

        if widthDiff < 0 {
            subtitleLabel.frame.origin.x = abs(widthDiff / 2)
        } else {
            titleLabel.frame.origin.x = widthDiff / 2
        }
        return titleView
    }
}


// MARK: - UITableViewDelegate

extension CollectionPhotosViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let image = images[indexPath.row]
        return CGFloat(image.height) / CGFloat(image.width) * UIScreen.main.bounds.width
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let uiImage = imagesCache[indexPath.row],
            let photoDetailController = storyboard?.instantiateViewController(withIdentifier: "PhotoDetailViewController") as? PhotoDetailViewController else { return }
        photoDetailController.image = images[indexPath.row]
        photoDetailController.regularResUIImage = uiImage
        photoDetailController.modalPresentationStyle = .overFullScreen
        photoDetailController.modalTransitionStyle = .crossDissolve
        present(photoDetailController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard currentPage < totalPages, indexPath.row + 1 == images.count else { return }
        currentPage += 1
        
        queryService.getCollectionPhotos(collectionId: collection.id, page: currentPage) { [weak self] newImages in
            guard let newImages = newImages else { return }
            self?.images += newImages
            self?.imagesCache.increase(by: newImages.count)
            self?.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        imagesCache.cancelDataTaskFor(row: indexPath.row)
    }
}


// MARK: - UITableViewDataSource

extension CollectionPhotosViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ImageTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        let row = indexPath.row
        let image = images[row]
        
        cell.authorLabel.text = image.user.name
        cell.likesLabel.text = "\(image.likes)"
        
        if let uiImage = imagesCache[row] {
            cell.uiImage = uiImage
        } else {
            let dataTask = queryService.downloadImageData(from: image.urls.regular) {
                [weak cell, weak self] data in
                guard let data = data, let uiImage = UIImage(data: data) else { return }
                self?.imagesCache[row] = uiImage
                cell?.uiImage = uiImage
            }
            imagesCache.setDataTask(dataTask, for: row)
        }
        return cell
    }
}


// MARK: - UITableViewDataSourcePrefetching

extension CollectionPhotosViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths where imagesCache[indexPath.row] == nil {
            let row = indexPath.row
            let dataTasks = queryService.downloadImageData(from: images[row].urls.regular) {
                [weak self] data in
                guard let data = data else { return }
                self?.imagesCache[row] = UIImage(data: data)
            }
            imagesCache.setDataTask(dataTasks, for: row)
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        imagesCache.cancelDataTasksFor(indexPaths: indexPaths)
    }
}
