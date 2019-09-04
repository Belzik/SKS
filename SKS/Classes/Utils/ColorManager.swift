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
    case gray
    case lightGray
    case black
    case lightBlack
    case blue
    case yellow
    
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
            instanceColor = UIColor(hexString: "#DA6C68")
        case .gray:
            instanceColor = UIColor(hexString: "#C8CAD2")
        case .lightGray:
            instanceColor = UIColor(hexString: "#A1A6B7")
        case .black:
            instanceColor = UIColor(hexString: "#666B7D")
        case .lightBlack:
            instanceColor = UIColor(hexString: "#333333")
        case .blue:
            instanceColor = UIColor(hexString: "#68B7FF")
        case .yellow:
            instanceColor = UIColor(hexString: "#D99D46")
            
        case .custom(let hexValue, let opacity):
            instanceColor = UIColor(hexString: hexValue).withAlphaComponent(CGFloat(opacity))
        }
        return instanceColor
    }
}
