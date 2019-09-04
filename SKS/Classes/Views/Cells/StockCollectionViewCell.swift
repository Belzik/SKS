//
//  StockCollectionViewCell.swift
//  SKS
//
//  Created by Александр Катрыч on 23/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class StockCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var leftConstraintMainView: NSLayoutConstraint!
    @IBOutlet weak var rightConstraintMainView: NSLayoutConstraint!
    
    weak var model: Stock? {
        didSet {
            layoutCell()
        }
    }

    func layoutCell() {
        //mainView.layer.cornerRadius = 12
        //mainView.backgroundColor = ColorManager.blue.value
        
        mainView.setupShadow(12,
                             shadowRadius: 10,
                             color: UIColor.black.withAlphaComponent(0.5),
                             offset: CGSize(width: 0, height: 0),
                             opacity: 0.3)
        
        if let model = model {
            titleLabel.text = model.name
            descriptionLabel.text = model.stockDescription
            periodLabel.text = "\(model.dateBegin) - \(model.dateEnd)"
        }
    }

}
