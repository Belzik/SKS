//
//  PartnerTableViewCell.swift
//  SKS
//
//  Created by Александр Катрыч on 22/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class PartnerTableViewCell: UITableViewCell {
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var discountView: UIView!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var stockImage: UIImageView!
    
    weak var model: PartnerHome? {
        didSet {
            layoutCell()
        }
    }

    private func layoutCell() {
        mainImage.image = model?.image
        titleLabel.text = model?.title
        descriptionLabel.text = model?.description
        discountView.layer.cornerRadius = 5
        discountLabel.text = model?.discount
        if let isStock = model?.isStock {
            if isStock {
                stockImage.isHidden = false
            } else {
                stockImage.isHidden = true
            }
        }
    }

}
