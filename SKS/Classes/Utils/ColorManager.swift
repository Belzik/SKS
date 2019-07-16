//
//  ColorManager.swift
//  SKS
//
//  Created by Александр Катрыч on 15/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

enum ColorManager {
    case green
    case red
    
    case custom(hexString: String, alpha: Double)
    
    func withAlpha(_ alpha: Double) -> UIColor {
        return self.value.withAlphaComponent(CGFloat(alpha))
    }
}

extension ColorManager {
    var value: UIColor {
        var instanceColor = UIColor.clear
        
        switch self {
        case .green:
            instanceColor = UIColor(hexString: "#1AAB58")
        case .red:
            instanceColor = UIColor(hexString: "#EC6464")

        case .custom(let hexValue, let opacity):
            instanceColor = UIColor(hexString: hexValue).withAlphaComponent(CGFloat(opacity))
        }
        return instanceColor
    }
}
