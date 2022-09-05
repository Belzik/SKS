//
//  TabBarViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 21/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    // MARK: View life cycle

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
        getNumberUnreadNews()
    }

    // MARK: - Methods
    
    func handlePosts() {
                NotificationCenter.default.addObserver(self, selector: #selector(self.setTabbarControllerIndexAction), name: NSNotification.Name(rawValue: "setTabbarControllerIndexAction"), object: nil)
    }
    
    @objc func setTabbarControllerIndexAction() {
        selectedIndex = 1
    }

    private func getNumberUnreadNews() {
        NetworkManager.shared.getNumberUnreadNessages { [weak self] result in
            self?.setupNewsTab(count: result.value?.count)
        }
    }

    func setupNewsTab(count: Int?) {
        let newsTab = tabBar.items?.first
        if let count = count,
           count > 0 {
            newsTab?.image = UIImage(named: "ic_newsUnselectedRead")
            newsTab?.selectedImage = UIImage(named: "ic_newsSelectedUnread")
        } else {
            newsTab?.image = UIImage(named: "ic_news_unselected")
            newsTab?.selectedImage = UIImage(named: "ic_news")
        }
    }
}

// MARK: UITabBarDelegate

extension TabBarViewController {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        getNumberUnreadNews()
    }
}
