//
//  SKSButton.swift
//  SKS
//
//  Created by Александр Катрыч on 15/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

enum TypeOfButton: Int {
    case background = 0
    case shadowAndBackground = 1
}

class SKSButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        configurationView()
    }
    
    private func configurationView() {
        backgroundColor = ColorManager.green.value
        layer.cornerRadius = 5
    }
}
