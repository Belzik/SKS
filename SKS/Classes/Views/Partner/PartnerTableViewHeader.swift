//
//  PartnerTableViewHeader.swift
//  SKS
//
//  Created by Александр Катрыч on 18/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

protocol PartnerTableViewHeaderDelegate: class {
    func backButtonTapped()
}

class PartnerTableViewHeader: UITableViewHeaderFooterView {
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var imageHeader: UIImageView!
    
    weak var delegate: PartnerTableViewHeaderDelegate?
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        delegate?.backButtonTapped()
    }
    
    override func awakeFromNib() {
        categoryView.layer.cornerRadius = 5
    }
}
