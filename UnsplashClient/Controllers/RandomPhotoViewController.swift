//
//  RandomPhotoViewController.swift
//  UnsplashClient
//
//  Created by Максим Голов on 16.12.2020.
//

import UIKit

// MARK: RandomPhotoViewController

class RandomPhotoViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var randomImageView: UIImageView!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dividorLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likesImageView: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var reloadPhotoButton: UIButton!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    // MARK: - Segue Properties
    
    var image: Image!
    var initialImageData: Data!
    
    // MARK: - Private Properties
    
    private let queryService = QueryService()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        likesImageView.layer.dropShadow(opacity: 0.3, radius: 5)
        likesLabel.layer.dropShadow(opacity: 0.7, radius: 5)
        reloadPhotoButton.layer.dropShadow(opacity: 0.5, radius: 5)
        randomImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))
        
        if let image = image {
            displayInfo(about: image)
        }
        if let data = initialImageData {
            randomImageView.image = UIImage(data: data)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientView.drawGradient()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        gradientView.drawGradient()
    }
    
    // MARK: - IBActions
    
    @IBAction func reloadPhotoButtonPressed(_ sender: UIButton) {
        coverView.isHidden = false
        loadingIndicator.startAnimating()
        loadRandomPhoto()
    }
    
    @IBAction func pinchGesture(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .ended {
            imageTapped()
        }
    }
    
    // MARK: - Private functions
    
    private func loadRandomPhoto() {
        queryService.getRandomPhotos(count: 1) { [weak self] images in
            guard let image = images?.first else { return }
            self?.image = image
            
            self?.queryService.downloadImageData(from: image.urls.regular) { [weak self] data in
                guard let data = data else { return }
                self?.displayInfo(about: image)
                self?.randomImageView.image = UIImage(data: data)
                self?.coverView.isHidden = true
                self?.loadingIndicator.stopAnimating()
            }
        }
    }
    
    private func displayInfo(about image: Image) {
        userNameLabel.text = image.user.name
        likesLabel.text = "\(image.likes)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        let dateString = dateFormatter.string(from: image.createdAt)
        
        if let description = image.description {
            descriptionLabel.text = description
            dividorLabel.text = "•"
            dateLabel.text = dateString
        } else {
            descriptionLabel.text = dateString
            dividorLabel.text = ""
            dateLabel.text = ""
        }
    }
    
    @objc private func imageTapped() {
        guard let photoDetailController = storyboard?.instantiateViewController(withIdentifier: "PhotoDetailViewController") as? PhotoDetailViewController,
              let image = image else { return }
        photoDetailController.image = image
        photoDetailController.regularResUIImage = randomImageView.image
        photoDetailController.modalPresentationStyle = .overFullScreen
        photoDetailController.modalTransitionStyle = .crossDissolve
        present(photoDetailController, animated: true)
    }
}
