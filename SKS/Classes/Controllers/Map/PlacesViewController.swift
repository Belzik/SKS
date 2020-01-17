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

    @IBOutlet weak var sortedView: UIView!
    @IBOutlet weak var sortedTextField: UITextField!
    @IBOutlet weak var sortedLabel: UILabel!
    
    @IBOutlet weak var placeView: UIView!
    
    var partners: [MapPartner] = []
    
    var picker = SKSPicker()
    var currentSort = "По рейтингу"
    var isSortedEditing = false
    
    var uuidCityPetr = "90f7c6f0-6bb8-4474-9693-93f216c84e65"
    var locManager = CLLocationManager()
    var latUser = ""
    var lngUser = ""
    var isFirstLoad = false
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showMapPointMap), name: NSNotification.Name(rawValue: "showMapPointMap"), object: nil)
    }
    
    @objc func hideMapPoint() {
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
            currentViewController = self.placeViewController
            self.add(asChildViewController: self.placeViewController)
            placeView.isHidden = false
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
            uuidCity = uuidCityPetr
        } else {
            latitude = latUser
            longitude = lngUser
        }
                
        NetworkManager.shared.getPartnersMap(uuidCity: uuidCity,
                                             uuidCategory: "",
                                             latUser: latitude,
                                             lngUser: longitude) { [weak self] result in
            if let value = result.result.value {
                self?.partners = value
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
