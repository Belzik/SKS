//
//  SalePointTableHeader.swift
//  SKS
//
//  Created by Александр Катрыч on 02/12/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

protocol SalePointTableHeaderDelegate: class {
    func onMapViewTapped()
}

class SalePointTableHeader: UITableViewHeaderFooterView {
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var mapView: UIView!
    
    weak var delegate: SalePointTableHeaderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let tap = UITapGestureRecognizer(target: self, action: #selector(onMapViewTapped))
        mapView.isUserInteractionEnabled = true
        mapView.addGestureRecognizer(tap)
    }
    
    @objc func onMapViewTapped() {
        delegate?.onMapViewTapped()
    }
}
