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
}
