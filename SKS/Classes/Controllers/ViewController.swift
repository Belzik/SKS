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
        
        NetworkManager.shared.getCategories { (response) in
            switch response.result {
            case .success(let json):
                if let array = json as? [[String: AnyObject]] {
                    for dictionary in array {
                        guard let category = Category(dictionary: dictionary) else { continue }
                        print(category.name)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
        
        NetworkManager.shared.getCities { (response) in
            switch response.result {
            case .success(let json):
                if let array = json as? [[String: AnyObject]] {
                    for dictionary in array {
                        guard let city = City(dictionary: dictionary) else { continue }
                        print(city.name)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
        
        NetworkManager.shared.getShowcase { (response) in
            switch response.result {
            case .success(let json):
                if let array = json as? [[String: AnyObject]] {
                    for dictionary in array {
                        guard let stock = Stock(dictionary: dictionary) else { continue }
                        print(stock.name)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }


}

