//
//  SKSTextFIeld.swift
//  SKS
//
//  Created by Александр Катрыч on 15/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import SkyFloatingLabelTextField
import UIKit

class SKSTextField: SkyFloatingLabelTextField {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.tintColor = UIColor.gray
        self.selectedLineColor = ColorManager.green.value
        self.selectedTitleColor = UIColor.gray
        self.lineHeight = 1
        self.selectedLineHeight = 1
        self.titleFont = UIFont.systemFont(ofSize: 14)
        self.titleFormatter = { string in
            return string
        }
        
        self.errorColor = ColorManager.red.value
        self.lineErrorColor = ColorManager.red.value
        self.titleLabel.adjustsFontSizeToFitWidth = true
    }
}
