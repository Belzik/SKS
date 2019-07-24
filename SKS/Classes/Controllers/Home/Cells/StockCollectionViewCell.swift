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
    
    weak var model: StockHome? {
        didSet {
            layoutCell()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func layoutCell() {
        titleLabel.text = model?.title
        descriptionLabel.text = model?.description
        periodLabel.text = model?.period
        mainView.layer.cornerRadius = 12
        mainView.backgroundColor = UIColor(hexString: "#68B7FF")
    }

}
