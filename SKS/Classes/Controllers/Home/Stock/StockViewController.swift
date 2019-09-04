//
//  StockViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 17/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class StockViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var showSalesView: UIView!
    @IBOutlet weak var showSalesLabel: UILabel!
    @IBOutlet weak var showSalesIcon: UIImageView!
    
    var uuid: String = ""
    var header: StockTableViewHeader!
    var city: City?
    var salePointsAll: [SalePoint] = []
    var salePoints: [SalePoint] = []
    var isShowSalePoints: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showSalePoint))
        showSalesView.isUserInteractionEnabled = true
        showSalesView.addGestureRecognizer(tap)

        setupTableView()
        getStock()
    }

    private func getStock() {
        guard let uuidCity = city?.uuidCity else { return }
        
        activityIndicator.startAnimating()
        NetworkManager.shared.getStock(idStock: uuid,
                                       uuidCity: uuidCity) { [weak self] response in
            self?.activityIndicator.stopAnimating()
            if let stock = response.result.value {
                self?.layout(withModel: stock)
            } else {
                self?.showAlert(message: NetworkErrors.common)
            }
        }
    }
    
    private func layout(withModel model: Stock) {
        header.categoryLabel.text = model.category?.name
        if let hexColor = model.category?.hexcolor { header.categoryView.backgroundColor = UIColor(hexString: hexColor) }

        header.periodLabel.text = DateManager.shared.toPeriod(dateStart: model.dateBegin, dateEnd: model.dateEnd)
        header.nameLabel.text = model.name
        header.partnerLabel.text = model.partner?.name
        header.descriptionLabel.text = model.stockDescription
        if let city = city?.nameCity {
            header.cityLabel.text = "г. \(city)"
        }
        
        if let salePoints = model.cities?.first?.salePoints {
            self.salePointsAll = salePoints
            
            if salePointsAll.count > 2 {
                self.salePoints.append(salePointsAll[0])
                self.salePoints.append(salePointsAll[1])
            } else {
                showSalesView.isHidden = true
                self.salePoints = salePointsAll
            }
            
            tableView.reloadData()
        }
        
        tableView.isHidden = false
    }
    
    @objc private func showSalePoint() {
        var indexPaths: [IndexPath] = []
        let angle: CGFloat = isShowSalePoints ?  0 : .pi
        if isShowSalePoints {
            for (key, _) in salePoints.enumerated() {
                if key != 0 && key != 1 {
                    salePoints.remove(at: key)
                    indexPaths.append(IndexPath(row: key, section: 0))
                }
            }
            
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.showSalesLabel.text = "Все адреса"
                self?.view.layoutIfNeeded()
                self?.showSalesIcon.transform = CGAffineTransform(rotationAngle: angle)
            })
            tableView.deleteRows(at: indexPaths, with: .automatic)
            isShowSalePoints = false
        } else {
            var indexPaths: [IndexPath] = []
            
            for (key, value) in salePointsAll.enumerated() {
                if key != 0 && key != 1 {
                    salePoints.append(value)
                    indexPaths.append(IndexPath(row: key, section: 0))
                }
            }

            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.showSalesLabel.text = "Свернуть"
                self?.view.layoutIfNeeded()
                self?.showSalesIcon.transform = CGAffineTransform(rotationAngle: angle)
            })
            tableView.insertRows(at: indexPaths, with: .automatic)
            isShowSalePoints = true
        }
    }
}

extension StockViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.register(UINib(nibName: "\(AddressTableViewCell.self)",
            bundle: nil),
                           forCellReuseIdentifier: "\(AddressTableViewCell.self)")
        
        tableView.register(UINib(nibName: "\(StockTableViewHeader.self)",
                                 bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "\(StockTableViewHeader.self)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return salePoints.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(AddressTableViewCell.self)",
                                                 for: indexPath) as! AddressTableViewCell
        cell.model = salePoints[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "\(StockTableViewHeader.self)") as! StockTableViewHeader
    
        self.header = header
        return header
    }
}

