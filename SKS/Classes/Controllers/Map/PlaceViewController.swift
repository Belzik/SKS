
//
//  PlaceViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 12/01/2020.
//  Copyright © 2020 Katrych. All rights reserved.
//

import UIKit
import Cosmos


class PlaceViewController: UIViewController {
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var workTimeLabel: UILabel!
    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var officesView: UIView!
    @IBOutlet weak var countOfficesLabel: UILabel!
    
    var mapPoint: MapPoint?
    var mapPartner: MapPartner?
    
    @IBAction func routeButtonTapped(_ sender: UIButton) {
        openGoogleMap()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapDetail = UITapGestureRecognizer(target: self, action: #selector(detailViewTapped))
        detailView.isUserInteractionEnabled = true
        detailView.addGestureRecognizer(tapDetail)
        
        let tapOffices = UITapGestureRecognizer(target: self, action: #selector(officesViewTapped))
        officesView.isUserInteractionEnabled = true
        officesView.addGestureRecognizer(tapOffices)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if mapPoint != nil {
            setupMapPoint()
        }
        
        if mapPartner != nil {
            setupMapPartner()
        }
        
    }
    
    func openGoogleMap() {
        guard let lat = mapPartner?.point?.latitude, let latDouble =  Double(lat) else { return }
        guard let long = mapPartner?.point?.longitude, let longDouble =  Double(long) else { return }
            
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {  //if phone has an app
            if let url = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(latDouble),\(longDouble)&directionsmode=driving") {
                UIApplication.shared.open(url, options: [:])
            }
        } else {
            if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(latDouble),\(longDouble)&directionsmode=driving") {
                UIApplication.shared.open(urlDestination)
            }
        }
    }
    
    func setupMapPartner() {
        guard let model = mapPartner else { return }
        
        if let logo = model.logo,
            logo != "",
            let url = URL(string: NetworkManager.shared.baseURI + logo) {
            logoImageView.kf.setImage(with: url)
        }
        
        categoryLabel.text = model.categoryName
        
        if let strRating = model.rating,
            let rating = Double(strRating) {
            ratingView.rating = rating
        }
        
        titleLabel.text = model.legalName
        descriptionLabel.text = model.description
        addressLabel.text = model.point?.address
        
        if let distance = model.point?.distance,
            distance != -1 {
            distanceLabel.text = "\(distance) м"
        } else {
            distanceLabel.text = ""
        }
        
        if let timeWork = model.point?.timeWork {
            var string = ""
            for (index, day) in timeWork.enumerated() {
                if let name = day.name,
                    let startWork = day.startWork,
                    let endWork = day.endWork {
                    
                    
                    if index == timeWork.count - 1 {
                        if startWork == "Круглосуточно" ||
                            startWork == "Выходной" ||
                            startWork == "-"{
                            string += "\(name): \(startWork);"
                        } else {
                            string += "\(name): \(startWork) - \(endWork);"
                        }
                    } else {
                        if startWork == "Круглосуточно" ||
                            startWork == "Выходной" ||
                            startWork == "-"{
                            string += "\(name): \(startWork);\n"
                        } else {
                            string += "\(name): \(startWork) - \(endWork);\n"
                        }
                        
                    }
                }
            }
            
            workTimeLabel.text = string
        }
        
        if let countOffices = model.points?.count {
            countOfficesLabel.text = "\(countOffices)"
        }
        
    }

    func setupMapPoint() {
        guard let model = mapPoint else { return }
        
        if let logo = model.logo,
            logo != "",
            let url = URL(string: logo) {
            logoImageView.kf.setImage(with: url)
        } else if let illustrate = model.illustrate,
            let url = URL(string: NetworkManager.shared.baseURI + illustrate) {
            logoImageView.kf.setImage(with: url)
        }
        
        categoryLabel.text = model.categoryName
        
        if let strRating = model.rating,
            let rating = Double(strRating) {
            ratingView.rating = rating
        }
        
        titleLabel.text = model.legalName
        descriptionLabel.text = model.description
        addressLabel.text = model.address
        
        if let distance = model.distance,
            distance != -1 {
            distanceLabel.text = "\(distance) м"
        } else {
            distanceLabel.text = ""
        }
        
        if let timeWork = model.timework {
            var string = ""
            
            for (index, day) in timeWork.enumerated() {
                if let name = day.name,
                    let startWork = day.startWork,
                    let endWork = day.endWork {
                    
                    
                    if index == timeWork.count - 1 {
                        if startWork == "Круглосуточно" ||
                            startWork == "Выходной" ||
                            startWork == "-"{
                            string += "\(name): \(startWork);"
                        } else {
                            string += "\(name): \(startWork) - \(endWork);"
                        }
                    } else {
                        if startWork == "Круглосуточно" ||
                            startWork == "Выходной" ||
                            startWork == "-"{
                            string += "\(name): \(startWork);\n"
                        } else {
                            string += "\(name): \(startWork) - \(endWork);\n"
                        }
                        
                    }
                }
            }
            
            workTimeLabel.text = string
        }
        
        countOfficesLabel.text = ""
    }
    
    @objc func detailViewTapped() {
        
    }
    
    @objc func officesViewTapped() {
        
    }
}
