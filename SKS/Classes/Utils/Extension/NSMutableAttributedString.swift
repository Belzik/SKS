//
//  NSMutableAttributedString.swift
//  SKS
//
//  Created by Александр Катрыч on 15/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//
import UIKit

extension NSMutableAttributedString {
    
    func setColorForText(textForAttribute: String, withColor color: UIColor, isUnderline: Bool = false) {
        let range: NSRange = self.mutableString.range(of: textForAttribute, options: .caseInsensitive)

        if isUnderline {
            self.addAttribute(.underlineStyle,
                              value: NSUnderlineStyle.single.rawValue,
                              range: range)
        }
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }
    
}
