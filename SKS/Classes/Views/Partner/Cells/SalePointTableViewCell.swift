//
//  SalePointTableViewCell.swift
//  SKS
//
//  Created by Александр Катрыч on 02/12/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class SalePointTableViewCell: UITableViewCell {
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var model: SalePoint? {
        didSet {
            setupUI()
        }
    }
    
    func setupUI() {
        guard let model = model else { return }
        
        addressLabel.text = model.address
        
        if let distance = model.distance,
            distance != -1 {
            distanceLabel.text = "\(distance) м"
        } else {
            distanceLabel.text = ""
        }
    }
    
}
