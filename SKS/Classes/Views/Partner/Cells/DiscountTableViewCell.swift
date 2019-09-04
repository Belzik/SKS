//
//  DiscountTableViewCell.swift
//  SKS
//
//  Created by Александр Катрыч on 20/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class DiscountTableViewCell: UITableViewCell {
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    weak var model: Discount? {
        didSet {
            layout()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func layout() {
        if let size = model?.size,
            let description = model?.discountDescription {
            sizeLabel.text = "Скидки \(size)%"
            descriptionLabel.text = description
        }
        
    }
}
