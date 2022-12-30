//
//  WorkInformationTableFooter.swift
//  Autonomy
//
//  Created by Alexander on 05/08/2019.
//  Copyright © 2019 Elvas. All rights reserved.
//

import UIKit

protocol CommentTableViewHeaderDelegate: class {
    func sendCommentButtonTapped()
}

class CommentTableViewHeader: UITableViewHeaderFooterView {
    @IBOutlet weak var assessmentView: UIView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var countScoreLabel: UILabel!
    
    @IBOutlet weak var oneProgressView: UIProgressView!
    @IBOutlet weak var twoProgressView: UIProgressView!
    @IBOutlet weak var thirdProgressView: UIProgressView!
    @IBOutlet weak var fourProgressView: UIProgressView!
    @IBOutlet weak var fiveProgressView: UIProgressView!
    
    @IBOutlet weak var sendCommentButton: DownloadButton!
    @IBOutlet weak var sendCommentButtonBottomConstraint: NSLayoutConstraint!
    
    @IBAction func sendCommentButtonTapped(_ sender: DownloadButton) {
        delegate?.sendCommentButtonTapped()
    }
    
    weak var delegate: CommentTableViewHeaderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        assessmentView.layer.cornerRadius = 5
        assessmentView.layer.borderColor = ColorManager.gray.value.cgColor
        assessmentView.layer.borderWidth = 0.5
        

    }

    func layout(withStatistic statistic: RatingStatistic, withPartner partner: Partner) {
        ratingLabel.text = partner.rating
        
        if let count = statistic.count {
            countScoreLabel.text = "\(count) оценок"
        }
        
        oneProgressView.progress = 0
        twoProgressView.progress = 0
        thirdProgressView.progress = 0
        fourProgressView.progress = 0
        fiveProgressView.progress = 0
        
        guard let count = statistic.count else { return }
        
        if let one = statistic.one {
            let percent = Float(one) / Float(count)
            oneProgressView.progress = percent
        }
        
        if let two = statistic.two {
            let percent = Float(two) / Float(count)
            twoProgressView.progress = percent
        }
        
        if let third = statistic.three {
            let percent = Float(third) / Float(count)
            thirdProgressView.progress = percent
        }
        
        if let four = statistic.four {
            let percent = Float(four) / Float(count)
            fourProgressView.progress = percent
        }
        
        if let five = statistic.five {
            let percent = Float(five) / Float(count)
            fiveProgressView.progress = percent
        }
        
        if UserData.loadSaved() == nil {
            sendCommentButton.isHidden = true
            sendCommentButtonBottomConstraint.constant = 0
        } else {
            sendCommentButton.isHidden = false
            sendCommentButtonBottomConstraint.constant = 24
        }
    }
}
