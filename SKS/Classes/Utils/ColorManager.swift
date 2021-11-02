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
    case greenStock
    case blueStock
    case orangeStock
    case purpleStock
    case blueNews
    case orangeNews
    case purpleNews
    case selectedRed
    case _383C45
    case _EFF2F5
    case _B3B3B3
    case _767B8B
    
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
        case .greenStock:
            instanceColor = UIColor(hexString: "#199C51")
        case .blueStock:
            instanceColor = UIColor(hexString: "#259BCD")
        case .orangeStock:
            instanceColor = UIColor(hexString: "#F69420")
        case .purpleStock:
            instanceColor = UIColor(hexString: "#7C24ED")
        case .orangeNews:
            instanceColor = UIColor(hexString: "#EEAB28")
        case .purpleNews:
            instanceColor = UIColor(hexString: "#D57BEC")
        case .blueNews:
            instanceColor = UIColor(hexString: "#598AEA")
        case .selectedRed:
            instanceColor = UIColor(hexString: "#F75151")
        case ._383C45:
            instanceColor = UIColor(hexString: "#383C45")
        case ._EFF2F5:
            instanceColor = UIColor(hexString: "#EFF2F5")
        case ._B3B3B3:
            instanceColor = UIColor(hexString: "#B3B3B3")
        case ._767B8B:
            instanceColor = UIColor(hexString: "#767B8B")

        case .custom(let hexValue, let opacity):
            instanceColor = UIColor(hexString: hexValue).withAlphaComponent(CGFloat(opacity))
        }
        return instanceColor
    }
}
