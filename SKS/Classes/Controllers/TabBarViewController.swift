//
//  TabBarViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 21/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit
import YandexMobileMetrica

enum Tab: Int {
    case news
    case partners
    case map
    case barcode
    case profile

    var text: String {
        switch self {
        case .news: return "news"
        case .partners: return "partners"
        case .map: return "map"
        case .barcode: return "barcode"
        case .profile: return "profile"
        }
    }

    var session: String {
        switch self {
        case .news: return "session.news"
        case .partners: return "session.partners"
        case .map: return "session.map"
        case .barcode: return "session.barcode"
        case .profile: return "session.profile"
        }
    }
}

class TabBarViewController: UITabBarController {

    // MARK: Properties

    var timer = Timer()
    var seconds = 0

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

        timer = Timer.scheduledTimer(
            timeInterval: 1, target: self,
            selector: #selector(update),
            userInfo: nil,
            repeats: true
        )
    }

    @objc func update() {
        seconds += 1
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

    private func sendAnalytics(tab: Tab) {
        YMMYandexMetrica.reportEvent(tab.text)
    }

    private func sendSession(tab: Tab) {
        if seconds > 2 {
            YMMYandexMetrica.reportEvent(tab.session, parameters: ["seconds": seconds])
        }
        seconds = 0
    }
}

// MARK: UITabBarDelegate

extension TabBarViewController {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let tab = Tab(rawValue: selectedIndex) {
            sendSession(tab: tab)
        }

        if let index = tabBar.items?.firstIndex(where: { $0 == item }),
            let tab = Tab(rawValue: index) {
            sendAnalytics(tab: tab)
        }
        getNumberUnreadNews()
    }
}
