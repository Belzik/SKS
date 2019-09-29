//
//  SearchTableViewCell.swift
//  SKS
//
//  Created by Александр Катрыч on 15/09/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

enum TypeOfSearchCell {
    case partner
    case stock
}

protocol SearchTableViewCellType: class {
    var icon: String { get }
    var title: String { get }
    var description: String { get }
    var uuid: String { get }
    var type: TypeOfSearchCell { get }
}

class SearchTableViewCell: UITableViewCell {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var heightIcon: NSLayoutConstraint!
    @IBOutlet weak var widthIcon: NSLayoutConstraint!
    
    weak var model: SearchTableViewCellType? {
        didSet {
            layout()
        }
    }
    
    func layout() {
        if let model = model {
            titleLabel.text = model.title
            descriptionLabel.text = model.description
            
            if model.type == .partner {
                heightIcon.constant = 40
                widthIcon.constant = 40
                
                let url = URL(string: NetworkManager.shared.baseURI + model.icon)
                iconView.kf.setImage(with: url)
            } else {
                heightIcon.constant = 24
                widthIcon.constant = 40
                
                iconView.image = UIImage(named: model.icon)
            }
        }
    }
}
