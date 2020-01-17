//
//  PartnerTableViewCell.swift
//  SKS
//
//  Created by Александр Катрыч on 22/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit
import Kingfisher
import Cosmos

class PartnerTableViewCell: UITableViewCell {
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var firstDiscountView: UIView!
    @IBOutlet weak var firstDiscountLabel: UILabel!
    
    @IBOutlet weak var secondDiscountView: UIView!
    @IBOutlet weak var secondDiscountLabel: UILabel!
    
    @IBOutlet weak var thirdDiscountView: UIView!
    @IBOutlet weak var thirdDiscountLabel: UILabel!
    
    @IBOutlet weak var stockImage: UIImageView!

    
    weak var model: Partner? {
        didSet {
            layoutCell()
        }
    }

    private func layoutCell() {
        if let model = model {
            setupRatingView()
            
            if let logo = model.logo,
                logo != "" {
                //let url = URL(string: NetworkManager.shared.baseURI + logo),
                let url = URL(string: logo)
                mainImage.kf.setImage(with: url)
            } else if let link = model.illustrate {
                let url = URL(string: NetworkManager.shared.baseURI + link)
                mainImage.kf.setImage(with: url)
            }
            
            titleLabel.text = model.name
            descriptionLabel.text = model.partnerDescription
            
            if model.stocks?.count != 0 {
                stockImage.isHidden = false
            } else {
                stockImage.isHidden = true
            }
            
            firstDiscountView.layer.cornerRadius = 12
            secondDiscountView.layer.cornerRadius = 12
            thirdDiscountView.layer.cornerRadius = 12
            
            var sizeFirst: Int?
            var sizeSecond: Int?
            var sizeThird: Int?
            
            if let discounts = model.discounts {
                for (key, discount) in discounts.enumerated() {
                    switch key {
                    case 0: sizeFirst = discount.size
                    case 1: sizeSecond = discount.size
                    case 2: sizeThird = discount.size
                    default: break
                    }
                }
            }
            
            
            if let size = sizeFirst {
                firstDiscountLabel.text = String(describing: size) + " %"
            }
            
            if let size = sizeSecond {
                secondDiscountLabel.text = String(describing: size) + " %"
                secondDiscountView.isHidden = false
            } else {
                secondDiscountView.isHidden = true
            }
            
            if let size = sizeThird {
                thirdDiscountLabel.text = String(describing: size) + " %"
                thirdDiscountLabel.isHidden = false
            } else {
                thirdDiscountView.isHidden = true
            }
            
            if let rating = model.rating,
                let doubleRating = Double(rating) {
                ratingView.rating = doubleRating
            }
            
            ratingView.settings.updateOnTouch = false
        }

    }
    
    func setupRatingView() {
        
    }

}
