//
//  UIApplication.swift
//  SKS
//
//  Created by Александр Катрыч on 24/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

extension UIApplication {
    class var statusBarBackgroundColor: UIColor? {
        get {
            return (shared.value(forKey: "statusBar") as? UIView)?.backgroundColor
        } set {
            (shared.value(forKey: "statusBar") as? UIView)?.backgroundColor = newValue
        }
    }
}
