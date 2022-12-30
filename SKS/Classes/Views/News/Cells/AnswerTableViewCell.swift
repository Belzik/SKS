//
//  AnswerTableViewCell.swift
//  SKS
//
//  Created by Александр Катрыч on 14/12/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit
import SnapKit

class AnswerTableViewCell: UITableViewCell {
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!

    var indexPath: IndexPath?
    weak var model: QuestionNew? {
        didSet {
            layoutUI()
        }
    }
    var checkbox: [Checkbox] = []
    var radioButtons: [SKSRadioButton] = []
    var textField: SKSTextField?
    
    func layoutUI() {
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
        }

        checkbox = []
        radioButtons = []
        guard let model = model else { return }
        
        questionLabel.text = model.question
        if let answers = model.answerVariants {
            for (index, answer) in answers.enumerated() {
                let view = UIView()
                view.tag = index

                let label = UILabel()
                label.numberOfLines = 0
                label.text = answer.answerVariant
                label.font = Fonts.openSans.regular.s16
                label.textColor = ColorManager._333333.value

                if let questionType = model.questionType,
                   questionType == "single" {
                    let button = SKSRadioButton()
                    button.delegate = self
                    button.tag = index

                    view.addSubview(button)
                    view.addSubview(label)
                    button.snp.makeConstraints {
                        $0.centerY.equalToSuperview()
                        $0.height.width.equalTo(24)
                        $0.left.equalToSuperview()
                    }

                    label.snp.makeConstraints {
                        $0.top.right.bottom.equalToSuperview()
                        $0.left.equalTo(button.snp.right).offset(8)
                    }

                    radioButtons.append(button)
                } else {
                    let button = Checkbox()
                    button.delegate = self
                    button.tag = index

                    view.addSubview(button)
                    view.addSubview(label)
                    button.snp.makeConstraints {
                        $0.centerY.equalToSuperview()
                        $0.height.width.equalTo(24)
                        $0.left.equalToSuperview()
                    }

                    label.snp.makeConstraints {
                        $0.top.right.bottom.equalToSuperview()
                        $0.left.equalTo(button.snp.right).offset(8)
                    }

                    checkbox.append(button)
                }

                let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapRecognized(_:)))
                view.addGestureRecognizer(tap)
                view.isUserInteractionEnabled = true
                view.backgroundColor = .white

                stackView.addArrangedSubview(view)
            }
        }

        if let allowOther = model.allowOther,
            allowOther {
            let view = UIView()
            if radioButtons.count == 0 {
                view.tag = checkbox.count
            } else {
                view.tag = radioButtons.count
            }

            let label = UILabel()
            label.numberOfLines = 0
            label.text = "Другое"
            label.font = Fonts.openSans.regular.s16
            label.textColor = ColorManager._333333.value

            if let questionType = model.questionType,
               questionType == "single" {
                let button = SKSRadioButton()
                button.delegate = self
                button.tag = view.tag

                view.addSubview(button)
                view.addSubview(label)
                button.snp.makeConstraints {
                    $0.centerY.equalToSuperview()
                    $0.height.width.equalTo(24)
                    $0.left.equalToSuperview()
                }

                label.snp.makeConstraints {
                    $0.top.bottom.equalToSuperview()
                    $0.left.equalTo(button.snp.right).offset(8)
                    $0.width.equalTo(55)
                }

                let textField = SKSTextField()
                setup(textField)
                self.textField = textField

                view.addSubview(textField)
                textField.snp.makeConstraints {
                    $0.bottom.equalToSuperview()
                    $0.right.equalToSuperview()
                    $0.left.equalTo(label.snp.right).offset(16)
                    $0.top.equalToSuperview().inset(-18)
                }

                radioButtons.append(button)
            } else {
                let button = Checkbox()
                button.delegate = self
                button.tag = view.tag

                view.addSubview(button)
                view.addSubview(label)
                button.snp.makeConstraints {
                    $0.centerY.equalToSuperview()
                    $0.height.width.equalTo(24)
                    $0.left.equalToSuperview()
                }

                label.snp.makeConstraints {
                    $0.top.bottom.equalToSuperview()
                    $0.left.equalTo(button.snp.right).offset(8)
                    $0.width.equalTo(55)
                }

                let textField = SKSTextField()
                textField.delegate = self
                setup(textField)
                self.textField = textField

                view.addSubview(textField)
                textField.snp.makeConstraints {
                    $0.bottom.equalToSuperview()
                    $0.right.equalToSuperview()
                    $0.left.equalTo(label.snp.right).offset(16)
                    $0.top.equalToSuperview().inset(-18)
                }

                checkbox.append(button)
            }

            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapAnother(_:)))
            view.addGestureRecognizer(tap)
            view.isUserInteractionEnabled = true

            stackView.addArrangedSubview(view)
        }
    }

    private func setup(_ textField: SKSTextField) {
        textField.tintColor = ColorManager.green.value
        textField.selectedLineColor = ColorManager.green.value
        textField.selectedTitleColor = ColorManager.lightGray.value
        textField.lineHeight = 1
        textField.selectedLineHeight = 1
        textField.lineColor = ColorManager.gray.value

        textField.titleColor = ColorManager.lightGray.value
        textField.titleFormatter = { string in
            return string
        }
        textField.font = Fonts.openSans.regular.s16

        let font = UIFont(name: "Montserrat-SemiBold", size: 12)!
        textField.titleFont = font

        textField.titleLabel.adjustsFontSizeToFitWidth = true
        textField.titleLabel.isHidden = true
    }

    @objc func tapRecognized(_ gesture: UITapGestureRecognizer) {
        if let view = gesture.view {
            if let questionType = model?.questionType,
               questionType == "single" {
                for button in radioButtons {
                    button.button.isSelected = false
                }

                if let answers = model?.answerVariants {
                    for answer in answers {
                        answer.isVoted = false
                    }
                }

                let button = radioButtons[view.tag]
                button.button.isSelected = !button.isSelected

                if let answers = model?.answerVariants {
                    answers[view.tag].isVoted = button.isSelected
                }
            } else {
                let button = checkbox[view.tag]
                button.button.isSelected = !button.isSelected

                if let answers = model?.answerVariants {
                    answers[view.tag].isVoted = button.isSelected
                }
            }
        }
    }

    @objc func tapAnother(_ gesture: UITapGestureRecognizer) {
        if let view = gesture.view {
            if let questionType = model?.questionType,
               questionType == "single" {
                for button in radioButtons {
                    button.button.isSelected = false
                }

                let button = radioButtons[view.tag]
                button.button.isSelected = !button.isSelected

                model?.isUserAnswerOther = button.isSelected
                model?.userAnswerOtherText = textField?.text ?? ""
            } else {
                let button = checkbox[view.tag]
                button.button.isSelected = !button.isSelected

                model?.isUserAnswerOther = button.isSelected
                model?.userAnswerOtherText = textField?.text ?? ""
            }
        }
    }
}

extension AnswerTableViewCell: SKSRadioButtonDelegate {
    func radioButtonTapped(radioButton: SKSRadioButton, isSelected: Bool) {
        guard let model = model else { return }

        if !isSelected {
            radioButton.button.isSelected = !radioButton.isSelected

            for button in radioButtons {
                if radioButton != button {
                    button.button.isSelected = false
                }
            }
        } else {
            for button in radioButtons {
                if radioButton != button {
                    button.button.isSelected = false
                }
            }
        }

        if let answers = model.answerVariants {
            if let allowOther = model.allowOther,
               allowOther,
               radioButton.tag == answers.count {
                model.isUserAnswerOther = radioButton.isSelected
                model.userAnswerOtherText = textField?.text ?? ""
            } else {
                answers[radioButton.tag].isVoted = radioButton.isSelected
            }
        }
    }
}


extension AnswerTableViewCell: CheckboxDelegate {
    func checboxTapped(checkbox: Checkbox, isSelected: Bool) {
        if let answers = model?.answerVariants {
            guard let model = model else { return }

            if let allowOther = model.allowOther,
               allowOther,
               checkbox.tag == answers.count {
                model.isUserAnswerOther = checkbox.isSelected
                model.userAnswerOtherText = textField?.text ?? ""
            } else {
                answers[checkbox.tag].isVoted = checkbox.isSelected
            }
        }
    }
}

// MARK: - UITextFieldDelegate

extension AnswerTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        model?.userAnswerOtherText = newString

        return true
    }
}
