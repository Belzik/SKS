//
//  DashboardMapViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 23.04.2021.
//  Copyright © 2021 Katrych. All rights reserved.
//

import UIKit
import Pulley

class DashboardMapViewController: PulleyViewController {
    
    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seguePartner" {
            let dvc = segue.destination as! TestViewController
            if let data = sender as?  (uuidPartner: String, uuidCity: String) {
                dvc.uuidPartner = data.uuidPartner
                dvc.uuidCity = data.uuidCity
            }
        }
    }

}

