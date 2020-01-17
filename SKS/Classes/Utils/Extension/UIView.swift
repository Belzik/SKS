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
    
    func setupShadow(_ radius: CGFloat, shadowRadius: CGFloat = 5, color: UIColor = UIColor.lightGray.withAlphaComponent(0.5), offset: CGSize = CGSize(width: 3, height: 3),  opacity: Float = 1, scale: Bool = true) {
        
        self.layer.cornerRadius = radius
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = opacity
        self.layer.masksToBounds = true
        clipsToBounds = false
        
//        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
//        layer.shouldRasterize = true
//        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func setupRoundeShadow() {
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.35).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 8
        self.layer.shadowOpacity = 0.3
        self.layer.masksToBounds = true
        clipsToBounds = false
    }
    
    func addConstraintWithFormatString(formate: String, views: UIView...) {
        var viewsDicitonary = [String: UIView]()
        
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDicitonary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: formate,
                                                      options: NSLayoutConstraint.FormatOptions.init(),
                                                      metrics: nil,
                                                      views: viewsDicitonary))
    }
}
