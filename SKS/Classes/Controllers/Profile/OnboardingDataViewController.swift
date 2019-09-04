//
//  OnboardingDataViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 27/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class OnboardingDataViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    var pageSource: PageSource?
    var index: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = pageSource?.image
        textLabel.text = pageSource?.text
    }

}
