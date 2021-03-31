//
//  TabBarViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 21/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.unselectedItemTintColor = ColorManager.black.value
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "OpenSans-Regular",
                                                                                              size: 10)!],
                                                         for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "OpenSans-Regular",
                                                                                              size: 10)!],
                                                         for: .selected)
        
        if UserData.loadSaved() != nil {
            selectedIndex = 1
        } else {
            selectedIndex = 4
        }
        handlePosts()
        
    }
    
    func handlePosts() {
                NotificationCenter.default.addObserver(self, selector: #selector(self.setTabbarControllerIndexAction), name: NSNotification.Name(rawValue: "setTabbarControllerIndexAction"), object: nil)
    }
    
    @objc func setTabbarControllerIndexAction() {
        selectedIndex = 1
    }
}
