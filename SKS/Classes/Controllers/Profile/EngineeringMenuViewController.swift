//
//  EngineeringMenuViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 18.04.2023.
//  Copyright © 2023 Katrych. All rights reserved.
//

import UIKit

class EngineeringMenuViewController: UIViewController {
    @IBOutlet weak var apiControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupApiControl()
    }

    func setupApiControl() {
        if NetworkManager.shared.apiEnvironment == .production {
            apiControl.selectedSegmentIndex = 0
        } else if NetworkManager.shared.apiEnvironment == .development {
            apiControl.selectedSegmentIndex = 1
        } else {
            apiControl.selectedSegmentIndex = 2
        }
    }

    @IBAction func apiControlValueChanged(_ sender: UISegmentedControl) {
        if apiControl.selectedSegmentIndex == 0 {
            NetworkManager.shared.apiEnvironment = .production
        } else if apiControl.selectedSegmentIndex == 1 {
            NetworkManager.shared.apiEnvironment = .development
        } else if apiControl.selectedSegmentIndex == 2 {
            NetworkManager.shared.apiEnvironment = .kuber
        }
        UserDefaults.standard.setApiEnvironment(index: apiControl.selectedSegmentIndex)
    }
}

extension UserDefaults {
    func setApiEnvironment(index: Int) {
        UserDefaults.standard.set(index, forKey: "ApiEnvIndex")
    }

    func getApiEnvironment() -> Int {
        UserDefaults.standard.value(forKey: "ApiEnvIndex") as? Int ?? 0
    }
}
