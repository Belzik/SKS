//
//  SalePointViewController.swift
//  SKS
//
//  Created by Alexander on 18/11/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit
import XLPagerTabStrip

protocol SalePointViewControllerDelegate: class {
    func scrollViewDidScroll(scrollView: UIScrollView, tableView: UITableView)
}

class SalePointViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var itemInfo = IndicatorInfo(title: "Торговые точки")
    weak var delegate: SalePointViewControllerDelegate?
    
    var city: City?
    var partner: Partner?
    var salePoints: [SalePoint] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(EnableScroll),
                                               name: NSNotification.Name(rawValue: "EnableScroll"),
                                               object: nil)
    }
    
    @objc func EnableScroll() {
       self.tableView.isScrollEnabled = true
    }
}

extension SalePointViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.register(UINib(nibName: "\(SalePointTableViewCell.self)", bundle: nil),
                           forCellReuseIdentifier: "\(SalePointTableViewCell.self)")
        
        tableView.register(UINib(nibName: "\(SalePointTableHeader.self)",
                                 bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "\(SalePointTableHeader.self)")
        
        // Для того, чтобы не плавал header
        let dummyViewHeight = CGFloat(40)
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyViewHeight))
        self.tableView.contentInset = UIEdgeInsets(top: -dummyViewHeight, left: 0, bottom: 0, right: 0)
        
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return salePoints.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(SalePointTableViewCell.self)",
                                                 for: indexPath) as! SalePointTableViewCell
        
        cell.model = salePoints[indexPath.row]
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView: scrollView, tableView: tableView)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "\(SalePointTableHeader.self)") as! SalePointTableHeader
            
        header.contentView.backgroundColor = .white
        
        return header
    }
}

extension SalePointViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
