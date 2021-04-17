//
//  CategoryFilterTableViewCell.swift
//  SKS
//
//  Created by Александр Катрыч on 16/11/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

protocol CategoryFilterTableViewCellDelegate: class {
    func checkboxTapped(indexPath: IndexPath)
}

class CategoryFilterTableViewCell: UITableViewCell {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkbox: Checkbox!
    
    var delegate: CategoryFilterTableViewCellDelegate?
    var indexPath: IndexPath?
    weak var model: Category? {
        didSet {
            layout()
        }
    }
    
    func layout() {
        checkbox.delegate = self
        
        if let model = model {
            titleLabel.text = model.name
                
            if let pict = model.pict {
                let url = URL(string: NetworkManager.shared.baseURI + pict)
                    iconView.kf.setImage(with: url) { [weak self] (image, _) in
                    if model.isSelected {
                        self?.titleLabel.textColor = ColorManager.green.value
                        
                        let newImage = self?.iconView.image?.withRenderingMode(.alwaysTemplate)
                        self?.iconView.tintColor = ColorManager.green.value
                        self?.iconView.image = newImage
                    } else {
                        self?.titleLabel.textColor = ColorManager.lightBlack.value
                        
                        let newImage = self?.iconView.image?.withRenderingMode(.alwaysTemplate)
                        self?.iconView.image = newImage
                        self?.iconView.tintColor = ColorManager.lightBlack.value
                    }
                }
            }
            

            checkbox.button.isSelected =  model.isSelected
            
            if model.isSelected {
                
            } else {
                
            }


        }
    }

}

extension CategoryFilterTableViewCell: CheckboxDelegate {
    func checboxTapped(checkbox: Checkbox, isSelected: Bool) {
        if let indexPath = indexPath {
            delegate?.checkboxTapped(indexPath: indexPath)
        }
    }
}
