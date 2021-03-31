//
//  PulleyPartnerViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 02/02/2020.
//  Copyright © 2020 Katrych. All rights reserved.
//

import UIKit
import Pulley



class PulleyPartnerViewController: PulleyViewController {
    var salePoint: SalePoint?
    var salePoints: [SalePoint]?
    var partner: Partner?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let mapVC = primaryContentViewController as? MapPartnerViewController {
            mapVC.salePoint = salePoint
            mapVC.partner = partner
            mapVC.salePoints = salePoints
            mapVC.delegate = self
            
            mapVC.setupSalePoints()
        }
        
        if let blindVC = drawerContentViewController as? BlindViewController {
            blindVC.salePoint = salePoint
            blindVC.partner = partner
            blindVC.salePoints = salePoints
            blindVC.delegate = self
            
            if salePoint != nil {
                blindVC.showSalePoint()
            }
            
            if salePoints != nil {
                blindVC.showSalePoints()
            }
        }
    }
}

extension PulleyPartnerViewController: BlindViewControllerDelegate {
    func salePointTapped(partner: MapPartner) {
        if let mapVC = primaryContentViewController as? MapPartnerViewController {
            mapVC.showPartner(mapPartner: partner)
        }
    }
}

extension PulleyPartnerViewController: MapPartnerViewControllerDelegate {
    func mapPointTapped(uuid: String) {
        if let blindVC = drawerContentViewController as? BlindViewController {
            blindVC.showPlace(uuid: uuid)
        }
    }
}
