//
//  BaseViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 19/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


}
