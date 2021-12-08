//
//  AboutPartnerViewController.swift
//  SKS
//
//  Created by Alexander on 18/11/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class AboutPartnerViewController: UIViewController {
    // MARK: - Views

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var linkLabel: UILabel! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(linkLabelTapped))
            linkLabel.isUserInteractionEnabled = true
            linkLabel.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var socialNetworksLabel: UILabel!
    @IBOutlet weak var instaButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var vkButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!

    // MARK: - Properties
    
    var vkLink = ""
    var fbLink = ""
    var instaLink = ""
    var twitterLink = ""
    var partner: Partner?
    var itemInfo = IndicatorInfo(title: "Описание")

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if let socialNetworks = partner?.socialNetworks {
            if socialNetworks.count > 0 {
                for socialNetwork in socialNetworks {
                    switch socialNetwork.type {
                    case "vk":
                        vkButton.isHidden = false
                        vkLink = socialNetwork.link ?? ""
                    case "fb":
                        facebookButton.isHidden = false
                        fbLink = socialNetwork.link ?? ""
                    case "instagram":
                        instaButton.isHidden = false
                        instaLink = socialNetwork.link ?? ""
                    case "twitter":
                        twitterButton.isHidden = false
                        twitterLink = socialNetwork.link ?? ""
                    default: continue
                    }
                }
            } else {
                socialNetworksLabel.isHidden = true
            }
        }
        
        nameLabel.text = partner?.name
        descriptionLabel.text = partner?.description
        if let linkToSite = partner?.linkToSite,
            linkToSite != "" {
            linkLabel.isHidden = false
            linkLabel.text = linkToSite
        } else {
            linkLabel.isHidden = true
        }
    }

    // MARK: - Actions

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

    @objc func linkLabelTapped() {
        if let link = partner?.linkToSite,
            let url = URL(string: link) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - IndicatorInfoProvider

extension AboutPartnerViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
