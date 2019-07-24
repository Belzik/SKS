//
//  ProfileViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 24/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var profileImage: UIImageView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileImage.makeCircular()
        profileImage.layer.masksToBounds = true
        profileImage.layer.borderColor = UIColor.white.cgColor
        profileImage.layer.borderWidth = 2.0
    }
    

}
