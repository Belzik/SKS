//
//  PoolingTableHeaderView.swift
//  SKS
//
//  Created by Александр Катрыч on 14/12/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit
import FSPagerView

class PoolingTableFooterView: UITableViewHeaderFooterView {
    // MARK: - Views

    @IBOutlet weak var doneButton: DownloadButton!
    @IBOutlet weak var contactButton: DownloadButton!

    // MARK: - Properties

    var doneHandler: (() -> Void)?
    var contactsHandler: (() -> Void)?

    // MARK: - Methods

    @IBAction func doneButtonTapped(_ sender: DownloadButton) {
        doneHandler?()
    }

    @IBAction func contactsButtonTapped(_ sender: DownloadButton) {
        contactsHandler?()
    }
}
