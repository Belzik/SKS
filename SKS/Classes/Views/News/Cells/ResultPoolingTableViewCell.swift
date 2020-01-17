//
//  ResultPoolingTableViewCell.swift
//  SKS
//
//  Created by Александр Катрыч on 14/12/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class ResultPoolingTableViewCell: UITableViewCell {
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
    weak var model: AnswerType? {
        didSet {
            layoutUI()
        }
    }
    
    func layoutUI() {
        guard let model = model else { return }
        
        answerLabel.text = model.title
        
        if let votes = model.votes {
            if model.allVotesCount > 0 {
                let percent = Float(votes) / Float(model.allVotesCount)

                progressView.progress = percent
                
                //percentLabel.text = "\((percent * 100).clean)%"
                
                percentLabel.text = "\(Int(percent * 100))%"
                countLabel.text = "\(votes)"
                

            } else {
                let percent = 0
                
                progressView.progress = 0
                percentLabel.text = "\(Int(percent * 100))%"
                countLabel.text = "\(votes)"
            }
            
            progressView.layer.cornerRadius = 5
            progressView.layer.masksToBounds = true
        }
    
        if let voted = model.voted {
            if voted {
                checkImageView.isHidden = false
            } else {
                checkImageView.isHidden = true
            }
        }
    }
    
}
