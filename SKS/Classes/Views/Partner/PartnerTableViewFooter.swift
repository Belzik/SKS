//
//  PartnerTableViewFooter.swift
//  SKS
//
//  Created by Александр Катрыч on 18/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

protocol PartnerTableViewFooterDelegate: class {
    func allPointsViewTapped()
}

class PartnerTableViewFooter: UITableViewHeaderFooterView {
    @IBOutlet weak var allPointsView: UIView!
    @IBOutlet weak var bottonPointsViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var instaButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var vkButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var showSalesLabel: UILabel!
    @IBOutlet weak var showSalesIcon: UIImageView!
    
    @IBOutlet weak var socialLabel: UILabel!
    @IBOutlet weak var separateView: UIView!
    @IBOutlet weak var bottomConstraintStack: NSLayoutConstraint!
    
    weak var delegate: PartnerTableViewFooterDelegate?
    var vkLink = ""
    var fbLink = ""
    var instaLink = ""
    var twitterLink = ""
    
    @IBAction func vkButtonTapped(_ sender: UIButton) {
        if let url = URL(string: vkLink) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func fbButtonTapped(_ sender: UIButton) {
        if let url = URL(string: fbLink) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func instaButtonTapped(_ sender: UIButton) {
        if let url = URL(string: instaLink) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func twitterButtonTapped(_ sender: UIButton) {
        if let url = URL(string: twitterLink) {
            UIApplication.shared.open(url)
        }
    }
    
    override func awakeFromNib() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(allPointsViewTapped))
        allPointsView.isUserInteractionEnabled = true
        allPointsView.addGestureRecognizer(tap)
    }
    
    @objc func allPointsViewTapped() {
        delegate?.allPointsViewTapped()
    }
}
