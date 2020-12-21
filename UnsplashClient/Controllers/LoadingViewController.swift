//
//  LoadingViewController.swift
//  UnsplashClient
//
//  Created by Максим Голов on 21.12.2020.
//

import UIKit
import SwiftGifOrigin

// MARK: LoadingViewController

class LoadingViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var loadingImageView: UIImageView!
    
    // MARK: - Private Properties
    
    private let queryService = QueryService()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        loadingImageView.loadGif(asset: "Loading")
        
        guard let tabBarController = storyboard?.instantiateViewController(withIdentifier: "RootTabBarController") as? UITabBarController,
              let randomPhotoController = tabBarController.viewControllers?[0] as? RandomPhotoViewController else { return }
        
        tabBarController.modalPresentationStyle = .overFullScreen
        tabBarController.modalTransitionStyle = .crossDissolve
        
        queryService.getRandomPhotos(count: 1) { [weak self] images in
            guard let image = images?.first else {
                self?.showErrorAlert()
                self?.present(tabBarController, animated: true)
                return
            }
            randomPhotoController.image = image
            
            self?.queryService.downloadImageData(from: image.urls.regular) { [weak self] data in
                if data == nil {
                    self?.showErrorAlert()
                }
                randomPhotoController.initialImageData = data
                self?.present(tabBarController, animated: true)
            }
        }
    }
    
    // MARK: - Private Functions
    
    private func showErrorAlert() {
        let alertController = UIAlertController(title: "Photo loading error", message: "Please check your internet connection or API request limit", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Close", style: .default))
        present(alertController, animated: true)
    }
}
