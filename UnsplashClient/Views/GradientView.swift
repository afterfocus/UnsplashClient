//
//  GradientView.swift
//  UnsplashClient
//
//  Created by Максим Голов on 17.12.2020.
//

import UIKit

class GradientView: UIView {
    func drawGradient() {
        layer.sublayers?.removeAll()
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        gradientLayer.locations = [0, 1]
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.6).cgColor,
                                UIColor.black.withAlphaComponent(0).cgColor]
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
