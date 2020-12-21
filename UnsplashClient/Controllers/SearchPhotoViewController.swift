//
//  SeachPhotoViewController.swift
//  UnsplashClient
//
//  Created by Максим Голов on 16.12.2020.
//

import UIKit
import TUSafariActivity
import ARChromeActivity

// MARK: SearchPhotoViewController

class SearchPhotoViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Private Properties
    
    private let queryService = QueryService()
    private var images = [Image]()
    private var imagesCache: ImagesCache!
    private var searchTerm: String!
    private var currentPage = 0
    private var totalPages = 0
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search images..."
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        queryService.getRandomPhotos(count: 10) { [weak self] newImages in
            guard let newImages = newImages else { return }
            self?.images = newImages
            self?.imagesCache = ImagesCache(size: newImages.count)
            self?.tableView.reloadData()
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        let urlString = searchTerm != nil ?
            "https://unsplash.com/s/photos/\(searchTerm!)" : "https://unsplash.com"
        let activityViewController = UIActivityViewController(
                activityItems: [URL(string: urlString)!],
                applicationActivities: [TUSafariActivity(), ARChromeActivity()])
        present(activityViewController, animated: true)
    }
}


// MARK: - UISearchBarDelegate

extension SearchPhotoViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        self.searchTerm = searchTerm
        
        queryService.searchPhotos(searchTerm: searchTerm) { [weak self] searchResult in
            guard let searchResult = searchResult else { return }
            self?.images = searchResult.images
            self?.currentPage = 1
            self?.totalPages = searchResult.totalPages
            self?.imagesCache.recreate(newSize: searchResult.images.count)
            self?.tableView.reloadData()
            if !searchResult.images.isEmpty {
                self?.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
        }
    }
}


// MARK: - UITableViewDelegate

extension SearchPhotoViewController: UITableViewDelegate {
    
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
        guard indexPath.row + 1 == images.count,
              searchTerm != nil,
              currentPage < totalPages else { return }
        currentPage += 1
        
        queryService.searchPhotos(searchTerm: searchTerm, page: currentPage) { [weak self] searchResult in
            guard let newImages = searchResult?.images else { return }
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

extension SearchPhotoViewController: UITableViewDataSource {
    
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

extension SearchPhotoViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths where imagesCache[indexPath.row] == nil {
            let row = indexPath.row
            let dataTask = queryService.downloadImageData(from: images[row].urls.regular) {
                [weak self] data in
                guard let data = data else { return }
                self?.imagesCache[row] = UIImage(data: data)
            }
            imagesCache.setDataTask(dataTask, for: row)
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        imagesCache.cancelDataTasksFor(indexPaths: indexPaths)
    }
}
