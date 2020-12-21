//
//  CALayerExtension.swift
//  SpaceQuest
//
//  Created by Максим Голов on 05.12.2020.
//

import UIKit

extension CALayer {
    func dropShadow(color: CGColor = UIColor.black.cgColor,
                    opacity: Float,
                    offset: CGSize = .zero,
                    radius: CGFloat) {
        shadowColor = color
        shadowOpacity = opacity
        shadowOffset = offset
        shadowRadius = radius
        masksToBounds = false
    }
}
