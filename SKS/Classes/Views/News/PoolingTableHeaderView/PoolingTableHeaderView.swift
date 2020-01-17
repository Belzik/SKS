//
//  PoolingTableHeaderView.swift
//  SKS
//
//  Created by Александр Катрыч on 14/12/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

protocol PoolingTableHeaderViewDelegate: class {
    func backButtonTapped()
}

class PoolingTableHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var typeNewsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var topImageViewConstraint: NSLayoutConstraint! // -44
    @IBOutlet weak var heightImageView: NSLayoutConstraint! // 200
    
    @IBOutlet weak var typeNewsView: UIView!
    @IBOutlet weak var typeNewsTextLabel: UILabel!
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        delegate?.backButtonTapped()
    }
    
    weak var model: News? {
        didSet {
            layoutUI()
        }
    }
    weak var delegate: PoolingTableHeaderViewDelegate?
    
    func layoutUI() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = imageView.frame
        let colors = [
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.9).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        ]

        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.colors = colors

        imageView.layer.addSublayer(gradientLayer)
        
        if let photo = model?.photoUrl?.first,
            photo != "" {
            let url = URL(string: photo)
            imageView.kf.setImage(with: url)
            
            topImageViewConstraint.constant = -44
            heightImageView.constant = 200
        } else {
            topImageViewConstraint.constant = 0
            heightImageView.constant = 0
        }
        
        typeNewsView.layer.cornerRadius = 4
        if let typeNewsString = model?.typeNews {
            if let type = TypeNews.init(rawValue: typeNewsString) {
                var typeNews = ""
                switch type {
                case .federal:
                    typeNews = "Ф"
                    typeNewsView.backgroundColor = ColorManager.purpleNews.value
                case .region:
                    typeNews = "Р"
                    typeNewsView.backgroundColor = ColorManager.orangeNews.value
                case .university:
                    typeNews = "М"
                    typeNewsView.backgroundColor = ColorManager.blueNews.value
                }
                typeNewsTextLabel.text = typeNews
            }
        }
        
        if model?.pooling?.uuidPooling != nil {
            typeNewsLabel.text = "ОПРОС"
        } else if model?.event?.uuidEvent != nil {
            typeNewsLabel.text = "МЕРОПРИЯТИЕ"
        } else {
            typeNewsLabel.text = "НОВОСТЬ"
        }
        
        titleLabel.text = model?.title
        questionLabel.text = model?.pooling?.question
        
        if let dateString = model?.publishBegin {
            dateLabel.text = DateManager.shared.getDifferenceTime(from: dateString)
        }
        
        categoryView.layer.cornerRadius = 4
    }
}
