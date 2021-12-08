//
//  NewPartnerViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 07/11/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class NewPartnerViewController: BaseViewController {
    @IBOutlet weak var menuBarView: MenuTabsView!

    var currentIndex: Int = 0
    var tabs = ["Menu TAB 1", "Menu TAB 2", "Menu TAB 3", "Menu TAB 4", "Menu TAB 5"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        menuBarView.dataArray = tabs
        menuBarView.isSizeToSitCellsNeeded = true
        menuBarView.collectionView.backgroundColor = UIColor.white
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
}
