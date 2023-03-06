//
//  DiscountViewController.swift
//  SKS
//
//  Created by Alexander on 18/11/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit
import XLPagerTabStrip

protocol DiscountViewControllerDelegate: class {
    func scrollViewDidScroll(scrollView: UIScrollView, tableView: UITableView)
    func stockTapeed(uuid: String)
}

class DiscountViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var itemInfo = IndicatorInfo(title: "Скидки и акции")
    weak var delegate: DiscountViewControllerDelegate?
    
    var partner: Partner?
    var discounts: [Discount] = []
    var stocks: [Stock] = []
    
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
    
    func reloadData() {
        if let discounts = partner?.discounts {
            self.discounts = discounts
        }
        
        if let stocks = partner?.stocks {
            self.stocks = stocks
        }
        
        tableView.reloadData()
    }
}

extension DiscountViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.register(UINib(nibName: "\(DiscountTableViewCell.self)", bundle: nil),
                           forCellReuseIdentifier: "\(DiscountTableViewCell.self)")
        
        tableView.register(UINib(nibName: "\(StockTableViewCell.self)",
            bundle: nil),
                           forCellReuseIdentifier: "\(StockTableViewCell.self)")
        
        tableView.register(UINib(nibName: "\(TitleTableViewHeader.self)",
                                 bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "\(TitleTableViewHeader.self)")

        // Для того, чтобы не плавал header
        let dummyViewHeight = CGFloat(40)
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyViewHeight))
        self.tableView.contentInset = UIEdgeInsets(top: -dummyViewHeight + 24, left: 0, bottom: 0, right: 0)
        
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        //tableView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if stocks.count == 0 {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if stocks.count == 0 {
                return discounts.count
            } else {
                return 1
            }
        }
        
        return discounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && stocks.count != 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(StockTableViewCell.self)",
                for: indexPath) as! StockTableViewCell

            cell.setCollectionViewDataSourceDelegate(self)
            cell.collectionView.tag = 2

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(DiscountTableViewCell.self)",
                for: indexPath) as! DiscountTableViewCell
            
            cell.model = discounts[indexPath.row]
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "\(TitleTableViewHeader.self)") as! TitleTableViewHeader
        
        if section == 0 && stocks.count != 0 {
            header.nameLabel.text = "Акции"
        } else {
            header.nameLabel.text = "Скидки"
        }
            
        header.contentView.backgroundColor = .white
        
        return header
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
    
}

extension DiscountViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

extension DiscountViewController: UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stocks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(StockCollectionViewCell.self)",
            for: indexPath) as! StockCollectionViewCell

        if indexPath.row == 0 {
            cell.leftConstraintMainView.constant = 16
        } else {
            cell.leftConstraintMainView.constant = 4
        }

        if indexPath.row == stocks.count - 1 &&
            stocks.count > 1 {
            cell.rightConstraintMainView.constant = 16
        } else {
            cell.rightConstraintMainView.constant = 4
        }
        
        if indexPath.row == 0 {
            stocks[indexPath.row].typeImage = .orange
        }
        
        if indexPath.row == 1 {
            stocks[indexPath.row].typeImage = .green
        }
        
        if indexPath.row == 2 {
            stocks[indexPath.row].typeImage = .blue
        }
        
        cell.model = stocks[indexPath.row]

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width - 12, height: 176 + 40)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.stockTapeed(uuid: stocks[indexPath.row].uuid)
    }
}
