//
//  CommentTableViewCell.swift
//  SKS
//
//  Created by Alexander on 18/11/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

protocol CommentTableViewCellDelegate: class {
    func likeViewTapped(indexPath: IndexPath)
}

class CommentTableViewCell: UITableViewCell {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var commentTextLabel: UILabel!
    @IBOutlet weak var likeView: UIView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var answerView: UIView!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    var indexPath: IndexPath?
    weak var delegate: CommentTableViewCellDelegate?
    weak var model: Comment? {
        didSet {
            setupUI()
        }
    }

    func setupUI() {
        guard let model = model else { return }
        
        userImageView.makeCircular()
        if let photo = model.userCommentInfo?.photo {
            let url = URL(string: photo)
            userImageView.kf.setImage(with: url)
        }
        
        if let name = model.userCommentInfo?.name,
            let surname = model.userCommentInfo?.surname {
            userNameLabel.text = "\(name) \(surname)"
        } else {
            userNameLabel.text = "Пользователь удален"
        }
        
        commentTextLabel.text = model.commentInfo?.comment
        
        if let userLike = model.userLike {
            if userLike == "false" {
                likeImageView.image = UIImage(named: "ic_heart_gray")
                likeLabel.textColor = ColorManager.lightGray.value
            } else {
                likeImageView.image = UIImage(named: "ic_heart")
                likeLabel.textColor = ColorManager.green.value
            }
        }
        
        if let likes = model.commentInfo?.likes {
            likeLabel.text = "Нравится \(likes)"
        }
        
        if let createdAt = model.commentInfo?.createdAt {
            timeLabel.text = DateManager.shared.getDifferenceTime(from: createdAt)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeViewTapped))
        likeView.isUserInteractionEnabled = true
        likeView.addGestureRecognizer(tap)

        if let answer = model.answerInfo {
            answerView.layer.cornerRadius = 10
            answerLabel.text = answer.answer
        } else {
            answerView.isHidden = true
            bottomConstraint.constant = 0
        }
    }
    
    @objc func likeViewTapped() {
        if let indexPath = self.indexPath {
            delegate?.likeViewTapped(indexPath: indexPath)
        }
    }
}
