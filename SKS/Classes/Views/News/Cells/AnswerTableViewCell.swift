//
//  AnswerTableViewCell.swift
//  SKS
//
//  Created by Александр Катрыч on 14/12/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

protocol AnswerTableViewCellDelegate: class {
    func radioButtonTapped(indexPath: IndexPath)
}

class AnswerTableViewCell: UITableViewCell {
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var sksRadioButton: SKSRadioButton!

    weak var delegate: AnswerTableViewCellDelegate?
    var indexPath: IndexPath?
    weak var model: AnswerType? {
        didSet {
            layoutUI()
        }
    }
    
    func layoutUI() {
        guard let model = model else { return }
        
        sksRadioButton.button.isSelected = model.isSelected
        sksRadioButton.delegate = self
        
        answerLabel.text = model.title
    }
}

extension AnswerTableViewCell: SKSRadioButtonDelegate {
    func radioButtonTapped(radioButton: SKSRadioButton, isSelected: Bool) {
        guard let indexPath = self.indexPath else { return }
        delegate?.radioButtonTapped(indexPath: indexPath)
    }
}

