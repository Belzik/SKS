//
//  SelectedPointView.swift
//  SKS
//
//  Created by Александр Катрыч on 25/01/2020.
//  Copyright © 2020 Katrych. All rights reserved.
//

import UIKit

class SelectedPointView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var backgroundView: UIView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("\(SelectedPointView.self)", owner: self, options: nil)
        addSubview(contentView)
        
        logoImage.makeCircular()
        logoImage.layer.masksToBounds = true
        logoImage.layer.borderColor = UIColor.white.cgColor
        logoImage.layer.borderWidth = 2.0
        
        backgroundView.makeCircular()
        
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

}
