//
//  UIView.swift
//  SKS
//
//  Created by Александр Катрыч on 20/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

extension UIView {
    func makeCircular() {
        self.layer.cornerRadius = min(self.frame.size.height, self.frame.size.width) / 2.0
        self.clipsToBounds = true
    }
    
    func setupShadow(_ radius: CGFloat, shadowRadius: CGFloat = 5, color: UIColor = UIColor.lightGray.withAlphaComponent(0.5), offset: CGSize = CGSize(width: 3, height: 3),  opacity: Float = 1) {
        self.layer.cornerRadius = radius
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = opacity
        self.layer.masksToBounds = false
    }
}
