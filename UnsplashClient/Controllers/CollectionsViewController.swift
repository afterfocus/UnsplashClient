//
//  CollectionsViewController.swift
//  UnsplashClient
//
//  Created by Максим Голов on 16.12.2020.
//

import UIKit

// MARK: CollectionsViewController

class CollectionsViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Private Properties
    
    private let queryService = QueryService()
    private var collections = [PhotoCollection]()
    private var imagesCache: ImagesCache!
    private var currentPage = 1
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        queryService.getCollections() { [weak self] newCollections in
            guard let newCollections = newCollections else { return }
            self?.collections = newCollections
            self?.imagesCache = ImagesCache(size: newCollections.count)
            self?.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowCollectionPhotos",
              let cell = sender as? CollectionTableViewCell,
              let indexPath = tableView.indexPath(for: cell),
              let destination = segue.destination as? CollectionPhotosViewController else { return }
        destination.collection = collections[indexPath.row]
    }
}


// MARK: - UITableViewDelegate

extension CollectionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row + 1 == collections.count else { return }
        currentPage += 1
        
        queryService.getCollections(page: currentPage) { [weak self] newCollections in
            guard let newCollections = newCollections else { return }
            self?.collections += newCollections
            self?.imagesCache.increase(by: newCollections.count)
            self?.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        imagesCache.cancelDataTasksFor(indexPaths: [indexPath])
    }
}


// MARK: - UITableViewDataSource

extension CollectionsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        collections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CollectionTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        let row = indexPath.row
        let collection = collections[row]
        
        cell.titleLabel.text = collection.title
        cell.totalPhotosLabel.text = "\(collection.totalPhotos)"
        
        if let uiImage = imagesCache[row] {
            cell.uiImage = uiImage
        } else {
            let dataTask = queryService.downloadImageData(from: collections[row].coverPhoto.urls.regular) {
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

extension CollectionsViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths where imagesCache[indexPath.row] == nil {
            let row = indexPath.row
            let dataTask = queryService.downloadImageData(from: collections[row].coverPhoto.urls.regular) {
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

