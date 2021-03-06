//
//  AddressTableViewCell.swift
//  SKS
//
//  Created by Александр Катрыч on 17/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class AddressTableViewCell: UITableViewCell {
    @IBOutlet weak var addressLabel: UILabel!
    
    weak var model: SalePoint? {
        didSet {
            layout()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Убрать separator у ячейки
        separatorInset = UIEdgeInsets(top: 0, left: CGFloat.greatestFiniteMagnitude, bottom: 0, right: 0)
    }
    
    private func layout() {
        var addressText = ""
        if let address = model?.address {
            addressText = address
        }
        
//        if let workTime = model?.workTime {
//            addressText += ", " + workTime
//        }
        
        addressLabel.text = addressText
    }
}
