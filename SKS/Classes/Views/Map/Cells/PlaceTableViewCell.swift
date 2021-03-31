//
//  PlaceTableViewCell.swift
//  SKS
//
//  Created by Александр Катрыч on 16/11/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    

    weak var model: MapPartner? {
        didSet {
            layoutUI()
        }
    }
    
    func layoutUI() {
        categoryLabel.text = model?.categoryName
        titleLabel.text = model?.name
        
        ratingLabel.text = model?.rating
        
        addressLabel.text = model?.point?.address
        if let distance = model?.point?.distance {
            if distance == -1 {
                distanceLabel.text = ""
            } else {
                if distance > 1000 {
                    self.distanceLabel.text = "\(String(format:"%.1f", (Double(distance) / 1000))) км"
                } else {
                    self.distanceLabel.text = "\(distance) м"
                }
            }
        }
    }
}
