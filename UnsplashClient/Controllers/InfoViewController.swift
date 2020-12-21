//
//  InfoViewController.swift
//  UnsplashClient
//
//  Created by Максим Голов on 18.12.2020.
//

import UIKit

// MARK: - InfoContainerViewController

class InfoContainerViewController: UIViewController {
    
    // MARK: - Segue Properties
    
    var image: Image!
    
    // MARK: - View Life Cycle
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "InfoEmbedSegue" {
            let infoController = segue.destination as? InfoViewController
            infoController?.image = image
        }
    }
}


// MARK: - InfoViewController

class InfoViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var makeLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var dimensionsLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dividerViewHeight: NSLayoutConstraint!
    
    // MARK: - Segue Properties
    
    var image: Image!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        dividerViewHeight.constant = 1.0 / UIScreen.main.scale
        
        makeLabel.text = image.exif?.make ?? "—"
        modelLabel.text = image.exif?.model ?? "—"
        dimensionsLabel.text = "\(image.width) x \(image.height)"
        userLabel.text = image.user.name
        likesLabel.text = "\(image.likes)"
        descriptionLabel.text = image.description ?? "—"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        createdAtLabel.text = dateFormatter.string(from: image.createdAt)
    }
    
    // MARK: - IBActions
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
