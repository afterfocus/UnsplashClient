//
//  ImageTableViewCell.swift
//  UnsplashClient
//
//  Created by Максим Голов on 16.12.2020.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likesImageView: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var uiImage: UIImage? {
        get {
            photoImageView.image
        }
        set {
            photoImageView.image = newValue
            loadingIndicator.stopAnimating()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadingIndicator.startAnimating()
        authorLabel.layer.dropShadow(opacity: 0.5, radius: 5)
        likesLabel.layer.dropShadow(opacity: 0.5, radius: 5)
        likesImageView.layer.dropShadow(opacity: 0.15, radius: 4)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
        loadingIndicator.startAnimating()
    }
}
