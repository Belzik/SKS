//
//  StockCollectionViewCell.swift
//  SKS
//
//  Created by Александр Катрыч on 23/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//
import UIKit

enum StockImageType {
    case orange
    case green
    case blue
    case purple
}

class StockCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var stockImage: UIImageView!
    @IBOutlet weak var leftConstraintMainView: NSLayoutConstraint!
    @IBOutlet weak var rightConstraintMainView: NSLayoutConstraint!
    
    weak var model: Stock? {
        didSet {
            layoutCell()
        }
    }

    func layoutCell() {
        mainView.layer.cornerRadius = 12
        stockImage.layer.cornerRadius = 12
        
        if let model = model {
            titleLabel.text = model.name
            descriptionLabel.text = model.stockDescription
            periodLabel.text = "\(model.dateBegin) - \(model.dateEnd)"
            
            switch model.typeImage {
            case .orange:
                stockImage.image = UIImage(named: "orange_stock")
                mainView.backgroundColor = ColorManager.orangeStock.value
                model.typeImage = .orange

            case .green:
                stockImage.image = UIImage(named: "green_stock")
                mainView.backgroundColor = ColorManager.greenStock.value
                model.typeImage = .green

            case .blue:
                stockImage.image = UIImage(named: "blue_stock")
                mainView.backgroundColor = ColorManager.blueStock.value
                model.typeImage = .blue

            case .purple:
                stockImage.image = UIImage(named: "purple_stock")
                mainView.backgroundColor = ColorManager.purpleStock.value
                model.typeImage = .purple
            }
            
        }
    }


}
