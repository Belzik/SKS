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
        
        self.tintColor = UIColor.gray
        self.selectedLineColor = ColorManager.green.value
        self.selectedTitleColor = UIColor.gray
        self.lineHeight = 1
        self.selectedLineHeight = 1
        self.titleFont = UIFont.systemFont(ofSize: 14)
        self.titleFormatter = { string in
            return string
        }
    
        self.titleLabel.adjustsFontSizeToFitWidth = true
    }
}
