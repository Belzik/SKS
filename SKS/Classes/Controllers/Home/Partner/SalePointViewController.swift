//
//  SalePointViewController.swift
//  SKS
//
//  Created by Alexander on 18/11/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Pulley

protocol SalePointViewControllerDelegate: class {
    func scrollViewDidScroll(scrollView: UIScrollView, tableView: UITableView)
    func showSalePoints(salePoints: [SalePoint])
    func showSalePoint(salePoint: SalePoint)
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
        
        if let nameCity = city?.nameCity {
            header.cityLabel.text = "г. \(nameCity)"
        }
        
        header.delegate = self
        header.contentView.backgroundColor = .white
        
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.showSalePoint(salePoint: salePoints[indexPath.row])
        
        
//        if let tabbarController = tabBarController {
//            tabbarController.selectedIndex = 2
//
//            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
//                if let navVc = tabbarController.viewControllers?[2] as? UINavigationController {
//                    if let pulleyVC = navVc.viewControllers[0] as? PulleyViewController {
//                        if let mapVC = pulleyVC.primaryContentViewController as? MapViewController {
//                            mapVC.isFromPartner = true
//                            var logoString = ""
//                            if let logo = self?.partner?.logo,
//                                logo != "" {
//                                logoString = logo
//                                //logoImageView.kf.setImage(with: url)
//                            } else if let logoIllustrate = self?.partner?.category?.illustrate {
//                                logoString = NetworkManager.shared.baseURI + logoIllustrate
//                            }
//
//                            if let salePoint = self?.salePoints[indexPath.row] {
//                                mapVC.showSalePoint(salePoint: salePoint, logo: logoString)
//                            }
//
//                            if let partner = self?.partner,
//                                let salePoint = self?.salePoints[indexPath.row] {
//                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPartnerPlace"),
//                                                                object: nil,
//                                                                userInfo: ["partner": partner,
//                                                                           "salePoint": salePoint])
//                            }
//                        }
//                    }
//                }
//            }
//        }
    }
}

extension SalePointViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

extension SalePointViewController: SalePointTableHeaderDelegate {
    func onMapViewTapped() {
        delegate?.showSalePoints(salePoints: salePoints)
//        if let tabbarController = tabBarController {
//            tabbarController.selectedIndex = 2
//
//            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
//                if let navVc = tabbarController.viewControllers?[2] as? UINavigationController {
//                    if let pulleyVC = navVc.viewControllers[0] as? PulleyViewController {
//                        if let mapVC = pulleyVC.primaryContentViewController as? MapViewController {
//                            mapVC.isFromPartner = true
//
//                            if let salePoints = self?.salePoints,
//                                let partner = self?.partner {
//                                mapVC.showSalePoints(salePoints: salePoints, partner: partner)
//                            }
//
//                            if let partner = self?.partner,
//                                let salePoints = self?.salePoints {
//
//                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showSalePoints"),
//                                                                object: nil,
//                                                                userInfo: ["salePoints": salePoints,
//                                                                           "partner": partner])
//                            }
//                        }
//                    }
//                }
//            }
//        }
    }
}
