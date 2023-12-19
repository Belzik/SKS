//
//  AddressTableViewCell.swift
//  SKS
//
//  Created by Александр Катрыч on 17/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class PromocodeTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var iconView: UIImageView!

//    weak var model: SalePoint? {
//        didSet {
//            layout()
//        }
//    }

    override func awakeFromNib() {
        super.awakeFromNib()

        // Убрать separator у ячейки
        separatorInset = UIEdgeInsets(top: 0, left: CGFloat.greatestFiniteMagnitude, bottom: 0, right: 0)
        titleView.layer.cornerRadius = 20
    }

    private func layout() {}
}
