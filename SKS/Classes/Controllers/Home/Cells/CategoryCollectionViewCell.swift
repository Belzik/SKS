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
    @IBOutlet weak var checkedView: UIView!
    
    weak var model: CategoryHome? {
        didSet {
            layoutCell()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func layoutCell() {
        iconImageView.image = model?.image
        titleLabel.text = model?.title
        mainView.layer.cornerRadius = 12
        mainView.backgroundColor = model?.color
        checkedView.backgroundColor = UIColor(hexString: "#FF8642")
        checkedView.makeCircular()
        
        if let isChecked = model?.isSelect {
            if isChecked {
                checkedView.isHidden = false
            } else {
                checkedView.isHidden = true
            }
        }
    }
}
