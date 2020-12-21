//
//  CollectionTableViewCell.swift
//  UnsplashClient
//
//  Created by Максим Голов on 20.12.2020.
//

import UIKit

class CollectionTableViewCell: UITableViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var totalPhotosLabel: UILabel!
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
        titleLabel.layer.dropShadow(opacity: 0.5, radius: 5)
        totalPhotosLabel.layer.dropShadow(opacity: 0.5, radius: 5)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
        loadingIndicator.startAnimating()
    }
}
