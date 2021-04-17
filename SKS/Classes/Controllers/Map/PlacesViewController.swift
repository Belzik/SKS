//
//  PlacesViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 16/11/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit
import CoreLocation

class SortedItem: TypeOfSourcePicker {
    var title: String
    
    init(title: String) {
        self.title = title
    }
}

class PlacesViewController: UIViewController {
    @IBOutlet weak var gripperView: UIView!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var sortedView: UIView!
    @IBOutlet weak var sortedTextField: UITextField!
    @IBOutlet weak var sortedLabel: UILabel!
    
    @IBOutlet weak var placeView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var partners: [MapPartner] = []
    var savedPartners: [MapPartner] = []
    
    var picker = SKSPicker()
    var currentSort = "По рейтингу"
    var isSortedEditing = false
    
    var uuidCityPetr = "90f7c6f0-6bb8-4474-9693-93f216c84e65"
    var locManager = CLLocationManager()
    var latUser = ""
    var lngUser = ""
    var isFirstLoad = false
    var searchString = ""
    var uuidCategory = ""
    
    var isFakePartners = false
    
    private lazy var placeViewController: PlaceViewController = {
        let storyboard = UIStoryboard(name: "Map", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: "PlaceViewController") as! PlaceViewController
        
        return viewController
    }()
    
    var currentViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCityView()
        gripperView.layer.cornerRadius = 3
        setupTableView()
        setupNotificationCenter()
        
        setupLocManager()
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                getPoints()
            case .authorizedAlways, .authorizedWhenInUse:
                break
            @unknown default:
                break
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seguePlace" {
            let dvc = segue.destination as! PlaceViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                dvc.mapPartner = partners[indexPath.row]
            }
        }
    }
    
    func setupLocManager() {
        if CLLocationManager.locationServicesEnabled() {
            locManager.requestAlwaysAuthorization()
            locManager.requestWhenInUseAuthorization()
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyBest
            locManager.startUpdatingLocation()
        }
    }

    func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideMapPoint), name: NSNotification.Name(rawValue: "hideMapPoint"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideMapPointClose), name: NSNotification.Name(rawValue: "hideMapPointClose"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showMapPointMap), name: NSNotification.Name(rawValue: "showMapPointMap"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeSearchString), name: NSNotification.Name(rawValue: "changeSearchString"), object: nil)
        
                
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleCategory), name: NSNotification.Name(rawValue: "changeCategory"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showPartner), name: NSNotification.Name(rawValue: "showPartnerPlace"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showSalePoints), name: NSNotification.Name(rawValue: "showSalePoints"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideSalePoints), name: NSNotification.Name(rawValue: "hideSalePoints"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showMapPointSalePoint), name: NSNotification.Name(rawValue: "showMapPointSalePoint"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.changedCity), name: NSNotification.Name(rawValue: "changedCity"), object: nil)
    }
    
    @objc func changedCity() {
        getPoints()
    }
    
    @objc func showMapPointSalePoint(_ notification: NSNotification) {
        if let uuidSalePoint = notification.userInfo?["uuidSalePoint"] as? String {
//            let salePoint = salePointsObjects.first { object -> Bool in
//                if let data = object.userData as? (uuid: String, logo: String),
//                    let uuidSalePoint = mapPartner.point?.uuidSalePoint {
//                    return data.uuid == uuidSalePoint
//                }
//
//                return false
//            }
            let mapPartner = partners.first { object -> Bool in
                if let uuid = object.point?.uuidSalePoint {
                    return uuid == uuidSalePoint
                }
                return false
            }
            
            if let mapPartner = mapPartner {
                if let cv = currentViewController {
                    remove(asChildViewController: cv)
                }
                
                placeViewController.mapPoint = nil
                placeViewController.mapPartner = mapPartner
                
                placeViewController.partner = nil
                placeViewController.salePoint = nil
                    
                
                currentViewController = self.placeViewController
                self.add(asChildViewController: self.placeViewController)
                placeView.isHidden = false
            }

        }
    }
    
    @objc func showSalePoints(_ notification: NSNotification) {
        if let salePoints = notification.userInfo?["salePoints"] as? [SalePoint],
            let partner = notification.userInfo?["partner"] as? Partner {
            
            var fakePartners: [MapPartner] = []
            
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
                
                fakePartners.append(mapPartner)
            }
            

            
            partners = fakePartners
            
            tableView.reloadData()
            
            isFakePartners = true
            sortedView.isHidden = true
            categoryLabel.text = "Все филиалы"
        }
    }
    
    @objc func hideSalePoints() {
        if savedPartners.count == 0 {
            getPoints()
        } else {
            partners = savedPartners
            tableView.reloadData()
        }
        
        if !placeView.isHidden {
            if let cv = currentViewController {
                remove(asChildViewController: cv)
            }
            
            placeView.isHidden = true
        }
        
        isFakePartners = false
        sortedView.isHidden = false
        categoryLabel.text = "Все категории"
    }
    
    @objc func showPartner(_ notification: NSNotification) {
        if let partner = notification.userInfo?["partner"] as? Partner,
            let salePoint = notification.userInfo?["salePoint"] as? SalePoint {
            if let cv = currentViewController {
                remove(asChildViewController: cv)
            }
            
            placeViewController.mapPoint = nil
            placeViewController.mapPartner = nil
            
            placeViewController.partner = partner
            placeViewController.salePoint = salePoint
        }
        
        currentViewController = self.placeViewController
        self.add(asChildViewController: self.placeViewController)
        placeView.isHidden = false
    }
    
    @objc func handleCategory(_ notification: NSNotification) {
        if let uuidCategory = notification.userInfo?["uuidCategory"] as? String,
            let nameCategory = notification.userInfo?["nameCategory"] as? String {
            if uuidCategory == "" {
                categoryLabel.text = "Все категории"
            } else {
                categoryLabel.text = nameCategory
            }

            self.uuidCategory = uuidCategory
            isFakePartners = false
            
            getPoints()
        }
    }
    
    @objc func hideMapPoint() {
        if let cv = currentViewController {
            remove(asChildViewController: cv)
        }
        
        placeView.isHidden = true
        
        if isFakePartners {
            if savedPartners.count == 0 {
                getPoints()
            } else {
                partners = savedPartners
                tableView.reloadData()
            }
            
            if !placeView.isHidden {
                if let cv = currentViewController {
                    remove(asChildViewController: cv)
                }
                
                placeView.isHidden = true
            }
            
            isFakePartners = false
            sortedView.isHidden = false
            categoryLabel.text = "Все категории"
        }
    }
    
    @objc func hideMapPointClose() {
        if let cv = currentViewController {
            remove(asChildViewController: cv)
        }
        
        placeView.isHidden = true
    }
    
    @objc func showMapPointMap(_ notification: NSNotification) {
        if let point = notification.userInfo?["point"] as? MapPoint {
            if let cv = currentViewController {
                remove(asChildViewController: cv)
            }
            
            placeViewController.mapPartner = nil
            placeViewController.mapPoint = point
            
            placeViewController.partner = nil
            placeViewController.salePoint = nil
            
            currentViewController = self.placeViewController
            self.add(asChildViewController: self.placeViewController)
            placeView.isHidden = false
        }
    }
    
    @objc func changeSearchString(_ notification: NSNotification) {
        if let searchString = notification.userInfo?["searchString"] as? String {
            self.searchString = searchString
            getPoints()
        }
    }
    
    private func setupCityView() {
        picker.delegate = self
        picker.source = [
            SortedItem(title: "По рейтингу"),
            SortedItem(title: "Рядом с вами")
        ]
        
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(cityViewTapped))
        sortedView.isUserInteractionEnabled = true
        sortedView.addGestureRecognizer(tap)
        
        sortedTextField.inputAccessoryView = picker.toolBar
        sortedTextField.inputView = picker.picker
    }
    
    @objc func cityViewTapped() {
        if isSortedEditing {
            view.endEditing(true)
            isSortedEditing = false
        } else {
            sortedTextField.becomeFirstResponder()
            isSortedEditing = true
        }
    }
    
    func sortedPoints() {
        if currentSort == "По рейтингу" {
            partners.sort {
                Double($0.rating!)! > Double($1.rating!)!
            }
        } else {
            partners.sort {
                Double($0.point!.distance!) < Double($1.point!.distance!)
            }
        }
    }
    
    func showPlace() {
        if let indexPath = tableView.indexPathForSelectedRow {
            placeViewController.mapPoint = nil
            placeViewController.mapPartner = partners[indexPath.row]
            
            placeViewController.partner = nil
            placeViewController.salePoint = nil
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showMapPoint"),
                                            object: nil,
                                            userInfo: ["mapPoint": partners[indexPath.row]])
        }
        
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
    
    func getPoints() {
        var uuidCity = ""
        var latitude = ""
        var longitude = ""
        
        if latUser == "" {
            if let rememberCity = RememberCity.loadSaved() {
                if let uuid = rememberCity.uuidCity {
                    uuidCity = uuid
                }
            } else {
                uuidCity = uuidCityPetr
            }
        } else {
            latitude = latUser
            longitude = lngUser
        }
        
        activityIndicatorView.startAnimating()
        NetworkManager.shared.getPartnersMap(uuidCity: uuidCity,
                                             uuidCategory: uuidCategory,
                                             latUser: latitude,
                                             lngUser: longitude,
                                             searchString: searchString) { [weak self] result in
            self?.activityIndicatorView.stopAnimating()
            if let isFakePartners = self?.isFakePartners {
                if isFakePartners {
                    return
                }
            }
                   
            if let value = result.value {
                self?.partners = value
                self?.savedPartners = value
                self?.tableView.reloadData()
            }
        }
    }
}

extension PlacesViewController: UITableViewDelegate, UITableViewDataSource {
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
        //if isFakePartners { return }
        showPlace()
    }
}

extension PlacesViewController: SKSPickerDelegate {
    func donePicker(picker: SKSPicker, value: TypeOfSourcePicker) {
        if value.title == currentSort {
            view.endEditing(true)
            return
        }
        
        sortedLabel.text = value.title
        currentSort = value.title

        sortedPoints()
        tableView.reloadData()
        view.endEditing(true)
    }
    
    func cancelPicker() {
        view.endEditing(true)
    }
}

extension PlacesViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        let long = userLocation.coordinate.longitude;
        let lat = userLocation.coordinate.latitude;

        latUser = String(lat)
        lngUser = String(long)
        
        if !isFirstLoad {
            getPoints()
        }
        isFirstLoad = true
    }
}
