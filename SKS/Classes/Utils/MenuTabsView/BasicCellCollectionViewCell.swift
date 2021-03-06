//
//  BasicCellCollectionViewCell.swift
//  SKS
//
//  Created by Александр Катрыч on 10/11/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class BasicCell: UICollectionViewCell {
    let titleLabel: UILabel = {
        return UILabel()
    }()
    
    var indicatorView: UIView!
    
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.30) {
                self.indicatorView.backgroundColor = self.isSelected ? .blue : .clear
                self.layoutIfNeeded()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        addConstraintWithFormatString(formate: "H:|[v0]|", views: titleLabel)
        addConstraintWithFormatString(formate: "V:|[v0]|", views: titleLabel)
        
        addConstraint(NSLayoutConstraint.init(item: titleLabel,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerX,
                                              multiplier: 1,
                                              constant: 0))
        
        addConstraint(NSLayoutConstraint.init(item: titleLabel,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerY,
                                              multiplier: 1,
                                              constant: 0))
        
        setupIndicatorView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = ""
    }
    
    func setupIndicatorView() {
        indicatorView = UIView()
        addSubview(indicatorView)
        
        addConstraintWithFormatString(formate: "H:|[v0]|", views: indicatorView)
        addConstraintWithFormatString(formate: "V:|[v0(3)]|", views: titleLabel)
    }
}
