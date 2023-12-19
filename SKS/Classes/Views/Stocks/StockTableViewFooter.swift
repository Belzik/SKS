//
//  StockTableViewHeader.swift
//  SKS
//
//  Created by Александр Катрыч on 17/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class StockTableViewFooter: UITableViewHeaderFooterView {
    @IBOutlet weak var separateView: UIView!

    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var promocodeButton: UIButton!

    @IBOutlet weak var separateTwoView: UIView!
    @IBOutlet weak var promocodeLabel: UILabel!

    var promocodesHandler: (() -> Void)?
    var activateHandler: (() -> Void)?

    var model: CheckWinAbilityResponse? {
        didSet {
            layoutUI()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        buttonView.layer.cornerRadius = 24
        buttonView.backgroundColor = ColorManager.green.value

        titleLabel.text = "Активировать промокод"
        let tap = UITapGestureRecognizer(target: self, action: #selector(buttonViewTapped))
        buttonView.isUserInteractionEnabled = true
        buttonView.addGestureRecognizer(tap)
    }

    @IBAction func promocodesButtonTapped(_ sender: UIButton) {
        promocodesHandler?()
    }

    @objc func buttonViewTapped() {
        activateHandler?()
    }

    func layoutUI() {
        guard let model = model else { return }
        promocodeLabel.text = "ОСТАЛОСЬ ПРОМОКОДОВ: \(model.totalCodesRemaining)"
        descriptionLabel.text = "Доступно еще: \(model.userCodeRemaining) шт."

        if model.winAbility {
            separateTwoView.isHidden = false
            promocodeLabel.isHidden = false
            descriptionLabel.isHidden = false
            titleLabel.textColor = .white
            titleLabel.text = "Активировать промокод"
            buttonView.backgroundColor = ColorManager.green.value
            buttonView.isUserInteractionEnabled = true
        } else {
            separateTwoView.isHidden = true
            promocodeLabel.isHidden = true
            descriptionLabel.isHidden = true
            titleLabel.textColor = .white.withAlphaComponent(0.65)
            titleLabel.text = "Нет доступных промокодов"
            buttonView.backgroundColor = ColorManager.lightGray.value
            buttonView.isUserInteractionEnabled = false
        }
    }
}
