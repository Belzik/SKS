//
//  Checkbox.swift
//  Autonomy
//
//  Created by Alexander on 29/07/2019.
//  Copyright © 2019 Elvas. All rights reserved.
//

import UIKit

protocol CheckboxDelegate: class {
    func checboxTapped(checkbox: Checkbox, isSelected: Bool)
}

class Checkbox: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var button: UIButton!
    
    weak var delegate: CheckboxDelegate?
    
    var isSelected: Bool {
        return button.isSelected
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.checboxTapped(checkbox: self, isSelected: sender.isSelected)
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
        Bundle.main.loadNibNamed("\(Checkbox.self)", owner: self, options: nil)
        addSubview(contentView)
        
        button.setImage(UIImage(named:"ic_checkbox_default"), for: .normal)
        button.setImage(UIImage(named:"ic_checkbox_success"), for: .selected)
        button.isSelected = false
        
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

}
