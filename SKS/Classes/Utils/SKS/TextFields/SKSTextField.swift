//
//  SKSTextField.swift
//  SKS
//
//  Created by Александр Катрыч on 20/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import SkyFloatingLabelTextField
import UIKit

class SKSTextField: SkyFloatingLabelTextField {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.tintColor = ColorManager.green.value
        self.selectedLineColor = ColorManager.green.value
        self.selectedTitleColor = ColorManager.lightGray.value
        self.lineHeight = 1
        self.selectedLineHeight = 1
        self.lineColor = ColorManager.gray.value

        self.titleColor = ColorManager.lightGray.value
        self.titleFormatter = { string in
            return string
        }
        
        let font = UIFont(name: "Montserrat-SemiBold", size: 12)!
        self.titleFont = font
        
        self.titleLabel.adjustsFontSizeToFitWidth = true
        
    }
}
