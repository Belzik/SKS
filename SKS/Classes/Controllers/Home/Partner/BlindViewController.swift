//
//  BlindViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 02/02/2020.
//  Copyright © 2020 Katrych. All rights reserved.
//

import UIKit

protocol BlindViewControllerDelegate: class {
    func salePointTapped(partner: MapPartner)
}

class BlindViewController: BaseViewController {
    @IBOutlet weak var gripperView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var placeView: UIView!
    
    var salePoint: SalePoint?
    var partner: Partner?
    var salePoints: [SalePoint]?
    var partners: [MapPartner] = []
    
    private lazy var placeViewController: PlaceViewController = {
        let storyboard = UIStoryboard(name: "Map", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: "PlaceViewController") as! PlaceViewController
        
        return viewController
    }()
    
    var currentViewController: UIViewController?
    var delegate: BlindViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNotificationCenter()
        setupTableView()
    }
    
    func showPlace() {
        if let indexPath = tableView.indexPathForSelectedRow {
            placeViewController.mapPoint = nil
            placeViewController.mapPartner = partners[indexPath.row]
            
            placeViewController.partner = nil
            placeViewController.salePoint = nil
            
            placeViewController.isPartner = true
            
            delegate?.salePointTapped(partner: partners[indexPath.row])
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showMapPoint"),
//                                            object: nil,
//                                            userInfo: ["mapPoint": partners[indexPath.row]])
        }
        
        currentViewController = self.placeViewController
        self.add(asChildViewController: self.placeViewController)
        placeView.isHidden = false
    }
    

    func showPlace(uuid: String) {
        if let cv = currentViewController {
            remove(asChildViewController: cv)
        }
        
        let partner = partners.first { object -> Bool in
            if let uuidSalePoint = object.point?.uuidSalePoint {
                return uuid == uuidSalePoint
            }
            
            return false
        }
        
        placeViewController.mapPoint = nil
        placeViewController.mapPartner = partner
        
        placeViewController.partner = nil
        placeViewController.salePoint = nil
        
        placeViewController.isPartner = true
        
        currentViewController = self.placeViewController
        self.add(asChildViewController: self.placeViewController)
        placeView.isHidden = false
    }
    
    func add(asChildViewController viewController: UIViewController) {
        placeView.addSubview(viewController.view)
        
        viewController.view.frame = placeView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func remove(asChildViewController viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
    
    func showSalePoint() {
        if let cv = currentViewController {
            remove(asChildViewController: cv)
        }
        
        placeViewController.partner = partner
        placeViewController.salePoint = salePoint
        
        currentViewController = self.placeViewController
        self.add(asChildViewController: self.placeViewController)
        placeView.isHidden = false
    }
    
    func showSalePoints() {
        if let salePoints = salePoints,
            let partner = partner {
            
            for salePoint in salePoints {
                let pointPartner = PointPartner(address: salePoint.address,
                                                latitude: salePoint.latitude,
                                                longitude: salePoint.longitude,
                                                timeWork: salePoint.timeWork,
                                                distance: salePoint.distance,
                                                isOpenedNow: salePoint.isOpenedNow,
                                                uuidSalePoint: salePoint.uuidSalePoint)
                
                
                let mapPartner = MapPartner(categoryName: partner.category?.name,
                                            name: partner.name,
                                            rating: partner.rating,
                                            logo: partner.category?.illustrate,
                                            legalName: partner.legalName,
                                            description: partner.description,
                                            point: pointPartner)
                
                partners.append(mapPartner)
            }
            
            tableView.reloadData()
        }
    }
    
    func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideMapPointClose), name: NSNotification.Name(rawValue: "hideMapPointClose"), object: nil)
    }
    
    @objc func hideMapPointClose() {
        if let cv = currentViewController {
            remove(asChildViewController: cv)
        }
        
        placeView.isHidden = true
    }
}

extension BlindViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.register(UINib(nibName: "\(PlaceTableViewCell.self)", bundle: nil),
                           forCellReuseIdentifier: "\(PlaceTableViewCell.self)")
        
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return partners.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(PlaceTableViewCell.self)",
                                                 for: indexPath) as! PlaceTableViewCell
        
        cell.model = partners[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showPlace()
    }
}
