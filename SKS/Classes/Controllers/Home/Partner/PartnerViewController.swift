//
//  PartnerViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 18/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit
import Kingfisher

class PartnerViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var discounts: [Discount] = []
    var salePoints: [SalePoint] = []
    var city: City?
    var header: PartnerTableViewHeader?
    var footer: PartnerTableViewFooter?
    
    var salePointsAll: [SalePoint] = []
    var isShowSalePoints: Bool = false
    
    var uuidPartner: String = ""
    var stocks: [Stock] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        setupTableView()
        getPartner()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backButton = UIBarButtonItem(title: "Назад", style: .plain, target: nil, action: nil)
        backButton.tintColor = .black
        navigationItem.backBarButtonItem = backButton
        
        if segue.identifier == "segueStock",
            let uuidStock = sender as? String {
            let dvc = segue.destination as! StockViewController
            dvc.uuid = uuidStock
            dvc.city = city
        }
    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        self.navigationController?.setNavigationBarHidden(true, animated: animated)
//        super.viewWillAppear(animated)
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        self.navigationController?.setNavigationBarHidden(false, animated: animated)
//        super.viewWillDisappear(animated)
//    }
//    
    private func getPartner() {
        guard let uuidCIty = city?.uuidCity else { return }
        
        NetworkManager.shared.getPartner(uuidPartner: uuidPartner,
                                         uuidCity: uuidCIty) { [weak self] response in
            if let partner = response.result.value {
                self?.layout(withPartner: partner)
            } else {
                self?.showAlert(message: NetworkErrors.common)
            }
        }
    }
    
    private func layout(withPartner partner: Partner) {
        if let discounts = partner.discounts {
            self.discounts = discounts
        }
        
        if let stocks = partner.stocks {
            self.stocks = stocks
            header?.collectionView.reloadData()
        }
        
        header?.categoryLabel.text = partner.category?.name
        header?.nameLabel.text = partner.name
        header?.descriptionLabel.text = partner.partnerDescription
        
        if let hexcolor = partner.category?.hexcolor { header?.categoryView.backgroundColor = UIColor(hexString: hexcolor) }
        
        if let link = partner.category?.illustrateHeader,
            let url = URL(string: NetworkManager.shared.baseURI + link) {
            header?.imageHeader.kf.setImage(with: url)
        }
        
        if let salePoints = partner.cities?.first?.salePoints {
            self.salePointsAll = salePoints
            
//            if salePoints.count > 2 {
//                footer?.allPointsView.isHidden = false
//                footer?.bottonPointsViewConstraint.constant = 16
//                self.salePoints.append(salePointsAll[0])
//                self.salePoints.append(salePointsAll[1])
//            } else {
                footer?.allPointsView.isHidden = true
                footer?.bottonPointsViewConstraint.constant = -8
                self.salePoints = salePointsAll
            //}
        }
        
        if let socialNetworks = partner.socialNetworks {
            if socialNetworks.count > 0 {
                for socialNetwork in socialNetworks {
                    switch socialNetwork.type {
                    case "vk":
                        footer?.vkButton.isHidden = false
                        footer?.vkLink = socialNetwork.link ?? ""
                    case "fb":
                        footer?.facebookButton.isHidden = false
                        footer?.fbLink = socialNetwork.link ?? ""
                    case "instagram":
                        footer?.instaButton.isHidden = false
                        footer?.instaLink = socialNetwork.link ?? ""
                    case "twitter":
                        footer?.twitterButton.isHidden = false
                        footer?.twitterLink = socialNetwork.link ?? ""
                    default: continue
                    }
                }
            } else {
                footer?.socialLabel.isHidden = true
                footer?.separateView.isHidden = true
                footer?.bottomConstraintStack.constant = 0
            }
        }
        
        tableView.reloadData()
        tableView.isHidden = false
    }
}

extension PartnerViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.register(UINib(nibName: "\(DiscountTableViewCell.self)",
                                 bundle: nil),
                           forCellReuseIdentifier: "\(DiscountTableViewCell.self)")
        
        tableView.register(UINib(nibName: "\(AddressTableViewCell.self)",
                                 bundle: nil),
                           forCellReuseIdentifier: "\(AddressTableViewCell.self)")
        
        tableView.register(UINib(nibName: "\(PartnerSubtitleTableHeaderView.self)",
                                 bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "\(PartnerSubtitleTableHeaderView.self)")
        
        tableView.register(UINib(nibName: "\(PartnerTableViewHeader.self)",
                                 bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "\(PartnerTableViewHeader.self)")
        
        tableView.register(UINib(nibName: "\(PartnerTableViewFooter.self)",
                                 bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "\(PartnerTableViewFooter.self)")
        
        // Для того, чтобы не плавал header
        let dummyViewHeight = CGFloat(5000)
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyViewHeight))
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyViewHeight))
        self.tableView.contentInset = UIEdgeInsets(top: -dummyViewHeight, left: 0, bottom: -dummyViewHeight, right: 0)

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return discounts.count
        } else {
            return salePoints.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(DiscountTableViewCell.self)", for: indexPath) as! DiscountTableViewCell
            
            cell.model = discounts[indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(AddressTableViewCell.self)",
                for: indexPath) as! AddressTableViewCell
            
            cell.model = salePoints[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "\(PartnerTableViewHeader.self)") as! PartnerTableViewHeader
            header.delegate = self
            self.header = header
            header.setCollectionViewDataSourceDelegate(self)
            
            return header
        } else {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "\(PartnerSubtitleTableHeaderView.self)") as! PartnerSubtitleTableHeaderView
            if let nameCity = city?.nameCity { header.cityLabel.text = "г. \(nameCity)" }
            
            return header
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 {
            let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: "\(PartnerTableViewFooter.self)") as! PartnerTableViewFooter
            footer.delegate = self
            self.footer = footer
            return footer
        }

        return nil
    }
}

extension PartnerViewController: PartnerTableViewHeaderDelegate {
    func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension PartnerViewController: PartnerTableViewFooterDelegate {
    func allPointsViewTapped() {
        var indexPaths: [IndexPath] = []
        let angle: CGFloat = isShowSalePoints ?  0 : .pi
        if isShowSalePoints {
            var newSalePoints: [SalePoint] = []
            for (key, salePoint) in salePoints.enumerated() {
                if key == 0 || key == 1 {
                    newSalePoints.append(salePoint)
                } else {
                    indexPaths.append(IndexPath(row: key, section: 1))
                }
            }
            self.salePoints = newSalePoints
            
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.footer?.showSalesLabel.text = "Все адреса"
                self?.view.layoutIfNeeded()
                self?.footer?.showSalesIcon.transform = CGAffineTransform(rotationAngle: angle)
            })
            tableView.deleteRows(at: indexPaths, with: .automatic)
            isShowSalePoints = false
        } else {
            var indexPaths: [IndexPath] = []
            
            for (key, value) in salePointsAll.enumerated() {
                if key != 0 && key != 1 {
                    salePoints.append(value)
                    indexPaths.append(IndexPath(row: key, section: 1))
                }
            }
            
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.footer?.showSalesLabel.text = "Свернуть"
                self?.view.layoutIfNeeded()
                self?.footer?.showSalesIcon.transform = CGAffineTransform(rotationAngle: angle)
            })
            tableView.insertRows(at: indexPaths, with: .automatic)
            isShowSalePoints = true
        }
    }
    
    
}

extension PartnerViewController: UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
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
        
        if indexPath.row == stocks.count - 1 {
            cell.rightConstraintMainView.constant = 16
        } else {
            cell.rightConstraintMainView.constant = 4
        }
        
        cell.model = stocks[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width - 12, height: 160)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let uuidStock = stocks[indexPath.row].uuidStock {
            performSegue(withIdentifier: "segueStock", sender: uuidStock)
        }
    }
}
