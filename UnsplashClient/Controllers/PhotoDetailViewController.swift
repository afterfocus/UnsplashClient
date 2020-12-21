//
//  ViewController.swift
//  UnsplashClient
//
//  Created by Максим Голов on 15.12.2020.
//

import UIKit
import TUSafariActivity
import ARChromeActivity

// MARK: PhotoDetailViewController

class PhotoDetailViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    // MARK: - Segue Properties
    
    var image: Image!
    var regularResUIImage: UIImage!
    
    // MARK: - Private Properties
    
    private let queryService = QueryService()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        userNameLabel.layer.dropShadow(opacity: 0.7, radius: 5)
        closeButton.layer.dropShadow(opacity: 0.5, radius: 5)
        shareButton.layer.dropShadow(opacity: 0.5, radius: 5)
        infoButton.layer.dropShadow(opacity: 0.5, radius: 5)
        loadingIndicator.layer.dropShadow(opacity: 0.5, radius: 5)
        loadingIndicator.startAnimating()
        
        imageView.image = regularResUIImage
        userNameLabel.text = image.user.name
        queryService.downloadImageData(from: image.urls.full) { [weak self] data in
            guard let fullResData = data else { return }
            self?.imageView.image = UIImage(data: fullResData)
            self?.loadingIndicator.stopAnimating()
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
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        let activityViewController = UIActivityViewController(
            activityItems: [URL(string: image.links.html)!],
            applicationActivities: [TUSafariActivity(), ARChromeActivity()])
        present(activityViewController, animated: true)
    }
    
    @IBAction func infoButtonPressed(_ sender: UIButton) {
        guard let infoContainerController = storyboard?.instantiateViewController(withIdentifier: "InfoContainerViewController") as? InfoContainerViewController else { return }
        infoContainerController.image = image
        present(infoContainerController, animated: true)
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: - Gesture Recognizers
    
    @IBAction func singleTapGesture(_ sender: UITapGestureRecognizer) {
        animateControlsAlpha(to: gradientView.alpha == 1 ? 0 : 1)
    }
    
    @IBAction func doubleTapGesture(_ sender: UITapGestureRecognizer) {
        scrollView.setZoomScale(scrollView.zoomScale == 1 ? 3 : 1, animated: true)
    }
    
    // Жест закрытия контроллера
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
            case .changed:
                let translation = sender.translation(in: view)
                view.transform = CGAffineTransform(translationX: 0, y: max(0, translation.y))
                view.alpha = max(0, (170 - translation.y) / 170)
            case .ended:
                if sender.translation(in: view).y < 170 {
                    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut) {
                        self.view.transform = .identity
                        self.view.alpha = 1
                    }
                } else {
                    dismiss(animated: false)
                }
            default:
                break
            }
    }
    
    // MARK: - Private Functions
    
    private func animateControlsAlpha(to alpha: CGFloat) {
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseIn]) {
            [weak self] in
            self?.gradientView.alpha = alpha
            self?.userNameLabel.alpha = alpha
            self?.closeButton.alpha = alpha
            self?.shareButton.alpha = alpha
            self?.infoButton.alpha = alpha
        }
    }
}

// MARK: - UIScrollViewDelegate

extension PhotoDetailViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        panGestureRecognizer.isEnabled = scrollView.zoomScale == 1
    }
}


