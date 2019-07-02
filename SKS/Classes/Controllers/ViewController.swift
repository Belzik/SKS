//
//  ViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 29/06/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkManager.shared.getContent { (response) in
            switch response.result {
            case .success(let string):
                print(string)
            case .failure(let error):
                print(error)
            }
        }
        
        NetworkManager.shared.getCategories { result in
            if let error = result.error {
                print(error.localizedDescription)
            } else {
                print(result.value)
            }
        }
        
        NetworkManager.shared.getCities { result in
            if let error = result.error {
                print(error.localizedDescription)
            } else {
                print(result.value)
            }
        }
        
        NetworkManager.shared.getShowcase { result in
            if let error = result.error {
                print(error.localizedDescription)
            } else {
                print(result.value)
            }
        }
        
        NetworkManager.shared.getPartners { result in
            if let error = result.error {
                print(error.localizedDescription)
            } else {
                print(result.value)
            }
        }
    }


}

