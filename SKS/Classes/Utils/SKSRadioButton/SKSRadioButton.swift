//
//  SKSRadioButton.swift
//  SKS
//
//  Created by Александр Катрыч on 15/12/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

import UIKit

protocol SKSRadioButtonDelegate: class {
    func radioButtonTapped(radioButton: SKSRadioButton, isSelected: Bool)
}

class SKSRadioButton: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var button: UIButton!
    
    weak var delegate: SKSRadioButtonDelegate?
    
    var isSelected: Bool {
        return button.isSelected
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.radioButtonTapped(radioButton: self, isSelected: sender.isSelected)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("\(SKSRadioButton.self)", owner: self, options: nil)
        addSubview(contentView)
        
        button.setImage(UIImage(named:"ic_radiobutton_off"), for: .normal)
        button.setImage(UIImage(named:"ic_radiobutton_on"), for: .selected)
        button.isSelected = false
        
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

}
