//
//  CategoryCollectionViewCell.swift
//  SKS
//
//  Created by Александр Катрыч on 23/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var colorView: UIView!
    
    @IBOutlet weak var leftConstraintMainView: NSLayoutConstraint!
    @IBOutlet weak var rightConstraintMainView: NSLayoutConstraint!
    weak var model: Category? {
        didSet {
            layoutCell()
        }
    }

    func layoutCell() {
        if let model = model {
            if let link = model.pict {
                let url = URL(string: NetworkManager.shared.baseURI + link)
                iconImageView.kf.setImage(with: url) { [weak self] (image, _, _, _) in
                    if model.isSelected {
                        self?.titleLabel.textColor = .white
                        self?.colorView.backgroundColor = UIColor(hexString: "\(model.hexcolor!)")
                        
                        let newImage = self?.iconImageView.image?.withRenderingMode(.alwaysTemplate)
                        self?.iconImageView.tintColor = .white
                        self?.iconImageView.image = newImage
                    } else {
                        self?.colorView.backgroundColor = .white
                        self?.titleLabel.textColor = ColorManager.lightBlack.value
                        
                        let newImage = self?.iconImageView.image?.withRenderingMode(.alwaysTemplate)
                        self?.iconImageView.image = newImage
                        self?.iconImageView.tintColor = ColorManager.lightBlack.value
                    }
                }
            }
            
            titleLabel.text = model.name
        
            if model.isSelected {
                titleLabel.textColor = .white
                colorView.backgroundColor = UIColor(hexString: "\(model.hexcolor!)")
                
                mainView.setupShadow(12,
                                     shadowRadius: 2,
                                     color: UIColor.init(hexString: model.hexcolor!),
                                     offset: CGSize(width: 0, height: 0),
                                     opacity: 0.5)
                mainView.layer.cornerRadius = 12
                colorView.layer.cornerRadius = 12
            } else {
                colorView.backgroundColor = .white
                titleLabel.textColor = ColorManager.lightBlack.value
                
                mainView.setupShadow(12,
                                     shadowRadius: 7,
                                     color: UIColor.black.withAlphaComponent(0.5),
                                     offset: CGSize(width: 0, height: 0),
                                     opacity: 0.5)
                mainView.layer.cornerRadius = 12
                colorView.layer.cornerRadius = 12
            }
        }
    }
}
