//
//  NewsTableViewCell.swift
//  SKS
//
//  Created by Александр Катрыч on 24/11/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit
import Kingfisher

enum TypeNews: String {
    case federal = "federal"
    case region = "region"
    case university = "university"
}

class NewsTableViewCell: UITableViewCell {
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var topConstraintImageView: NSLayoutConstraint!
    @IBOutlet weak var heightImageView: NSLayoutConstraint!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var typeNewsView: UIView!
    @IBOutlet weak var typeNewsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        categoryView.layer.cornerRadius = 4
        typeNewsView.layer.cornerRadius = 4
    }

    weak var model: News? {
        didSet {
            layoutUI()
        }
    }
    
    func layoutUI() {
        if let photo = model?.photoUrl?.first,
            photo != "" {
            let url = URL(string: photo)
            newsImageView.kf.setImage(with: url)
            topConstraintImageView.constant = 16
            heightImageView.constant = 256
            contentLabel.numberOfLines = 2
        } else {
            topConstraintImageView.constant = 0
            heightImageView.constant = 0
            contentLabel.numberOfLines = 4
        }
        
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
                typeNewsLabel.text = typeNews
            }
        }
        
        if let hasPooling = model?.hasEvent,
           hasPooling {
            categoryLabel.text = "МЕРОПРИЯТИЕ"
        } else if let hasEvent = model?.hasPooling,
            hasEvent {
            categoryLabel.text = "ОПРОС"
        } else {
            categoryLabel.text = "НОВОСТЬ"
        }
        
        titleLabel.text = model?.title
        contentLabel.text = model?.content
        
        if let dateString = model?.publishBegin {
            timeLabel.text = DateManager.shared.getDifferenceTime(from: dateString)
        }
    }
}
