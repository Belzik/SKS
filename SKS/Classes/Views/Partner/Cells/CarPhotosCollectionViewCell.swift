//
//  CarPhotosCollectionViewCell.swift
//  SoloRentACar
//
//  Created by Alexander on 09/10/2019.
//  Copyright © 2019 solorentacar. All rights reserved.
//

import UIKit

class CarPhotosCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    var model: String? {
        didSet {
            setupUI()
        }
    }
    
    func setupUI() {
        if let model = model {
            imageView.image = UIImage(named: model)
        }
    }
}
