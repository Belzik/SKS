
//
//  PlaceViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 12/01/2020.
//  Copyright © 2020 Katrych. All rights reserved.
//

import UIKit
import Cosmos


class PlaceViewController: BaseViewController {
    
    // MARK: - IBOutlets
    
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
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var widthCloseButton: NSLayoutConstraint!
    @IBOutlet weak var leftConstrainCloseButton: NSLayoutConstraint!
    
    // MARK: - Properties
    
    var mapPoint: MapPoint?
    var mapPartner: MapPartner?
    
    var partner: Partner?
    var salePoint: SalePoint?
    
    var salePoints: [PointPartner] = []
    
    var isPartner = false
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapDetail = UITapGestureRecognizer(target: self, action: #selector(detailViewTapped))
        detailView.isUserInteractionEnabled = true
        detailView.addGestureRecognizer(tapDetail)
        
        let tapOffices = UITapGestureRecognizer(target: self, action: #selector(officesViewTapped))
        officesView.isUserInteractionEnabled = true
        officesView.addGestureRecognizer(tapOffices)
        
        if mapPoint != nil {
            setupMapPoint()
            //getMapPartner()
        }
        
        if mapPartner != nil {
            setupMapPartner()
        }
        
        if partner != nil {
            setupWithPartner()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //widthCloseButton.constant = 0
        //leftConstrainCloseButton.constant = 0
        
        if mapPoint != nil {
            setupMapPoint()
            //getMapPartner()
        }
        
        if mapPartner != nil {
            setupMapPartner()
        }
        
        if partner != nil {
            setupWithPartner()
        }
    }
    
    func openGoogleMap() {
        var latitude = ""
        var longitude = ""
        
        if let lat = mapPartner?.point?.latitude,
            let latDouble =  Double(lat) {
            latitude = String(describing: latDouble)
        }
        if let long = mapPartner?.point?.longitude,
            let longDouble =  Double(long) {
            longitude = String(describing: longDouble)
        }
        
        if let lat = mapPoint?.latitude,
            let latDouble =  Double(lat) {
            latitude = String(describing: latDouble)
        }
        if let long = mapPoint?.longitude,
            let longDouble =  Double(long) {
            longitude = String(describing: longDouble)
        }
        
        if let lat = salePoint?.latitude,
            let latDouble =  Double(lat) {
            latitude = String(describing: latDouble)
        }
        if let long = salePoint?.longitude,
            let longDouble =  Double(long) {
            longitude = String(describing: longDouble)
        }
            
        if latitude == "" { return }
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {  //if phone has an app
            if let url = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving") {
                UIApplication.shared.open(url, options: [:])
            }
        } else {
            if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving") {
                UIApplication.shared.open(urlDestination)
            }
        }
    }
    
    func getMapPartner() {
        var latitude = ""
        var longitude = ""
        var searchString = ""
        
        if let name = mapPoint?.name {
            searchString = name
        }
        
        if let location = LocationManager.shared.location {
            latitude = String(describing: location.coordinate.latitude)
            longitude = String(describing: location.coordinate.longitude)
        }
                
        NetworkManager.shared.getPartnersMap(uuidCity: "",
                                             uuidCategory: "",
                                             latUser: latitude,
                                             lngUser: longitude,
                                             searchString: searchString) { [weak self] result in
            
            if let value = result.value {
                if let points = value.first?.points {
                    self?.salePoints = points
                    self?.countOfficesLabel.text = "\(points.count)"
                }
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
        
        titleLabel.text = model.name
        descriptionLabel.text = model.description
        addressLabel.text = model.point?.address
        
        if let distance = model.point?.distance,
            distance != -1 {
            
            if distance > 1000 {
                self.distanceLabel.text = "\(String(format:"%.1f", (Double(distance) / 1000))) км"
            } else {
                self.distanceLabel.text = "\(distance) м"
            }
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
        
        if let isOpenedNow = model.point?.isOpenedNow,
            isOpenedNow {
            openLabel.text = "Открыто"
            openLabel.textColor = ColorManager.green.value
        } else {
            openLabel.text = "Закрыто"
            openLabel.textColor = ColorManager.red.value
        }
        
        if let countOffices = model.points?.count {
            countOfficesLabel.text = "\(countOffices)"
        }
        
        if model.uuidPartner == nil {
            widthCloseButton.constant = 24
            leftConstrainCloseButton.constant = 12
            //closeButton.isHidden = false
            detailView.isHidden = true
        } else {
            widthCloseButton.constant = 0
            leftConstrainCloseButton.constant = 0
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
        
        titleLabel.text = model.name
        descriptionLabel.text = model.description
        addressLabel.text = model.address
        
        if let distance = model.distance,
            distance != -1 {
            if distance > 1000 {
                self.distanceLabel.text = "\(String(format:"%.1f", (Double(distance) / 1000))) км"
            } else {
                self.distanceLabel.text = "\(distance) м"
            }
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
            
            if isPartner {
                widthCloseButton.constant = 24
                leftConstrainCloseButton.constant = 12
            } else {
                widthCloseButton.constant = 0
                leftConstrainCloseButton.constant = 0
            }
        }
        
        if let isOpenedNow = model.isOpenedNow,
            isOpenedNow {
            openLabel.text = "Открыто"
            openLabel.textColor = ColorManager.green.value
        } else {
            openLabel.text = "Закрыто"
            openLabel.textColor = ColorManager.red.value
        }
        
        detailView.isHidden = false
        
        countOfficesLabel.text = ""
    }
    
    func setupWithPartner() {
        guard let model = partner,
                let salePoint = salePoint else { return }
        
        if let logo = model.logo,
            logo != "",
            let url = URL(string: logo) {
            logoImageView.kf.setImage(with: url)
        } else if let illustrate = model.category?.illustrate,
            let url = URL(string: NetworkManager.shared.baseURI + illustrate) {
            logoImageView.kf.setImage(with: url)
        }
        
//        if let logo = partner?.logo,
//            logo != "",
//            let url = URL(string: logo) {
//            logoImageView.kf.setImage(with: url)
//        } else if let logoIllustrate = partner?.category?.illustrate,
//            let url = URL(string: baseURI + logoIllustrate) {
//            logoImageView.kf.setImage(with: url)
//        }
        
        //categoryLabel.text = model.categoryName
        categoryLabel.text = model.category?.name
        
        if let strRating = model.rating,
            let rating = Double(strRating) {
            ratingView.rating = rating
        }
        
        titleLabel.text = model.name
        descriptionLabel.text = model.description
        addressLabel.text = salePoint.address
        
        if let distance = salePoint.distance,
            distance != -1 {
                        
            if distance > 1000 {
                self.distanceLabel.text = "\(String(format:"%.1f", (Double(distance) / 1000))) км"
            } else {
                self.distanceLabel.text = "\(distance) м"
            }
        } else {
            distanceLabel.text = ""
        }
        
        if let timeWork = salePoint.timeWork {
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
        
        if let isOpenedNow = salePoint.isOpenedNow,
            isOpenedNow {
            openLabel.text = "Открыто"
            openLabel.textColor = ColorManager.green.value
        } else {
            openLabel.text = "Закрыто"
            openLabel.textColor = ColorManager.red.value
        }
        
        detailView.isHidden = true
        widthCloseButton.constant = 0
        leftConstrainCloseButton.constant = 0
        
        countOfficesLabel.text = ""
    }
    
    @objc func detailViewTapped() {
        var uuidCity = ""
        var uuidPartner = ""
        
        if let uuidCt = mapPartner?.point?.uuidCity,
            let uuidPr =  mapPartner?.uuidPartner {
            uuidCity = uuidCt
            uuidPartner = uuidPr
        }
        
        if let uuidCt = mapPoint?.uuidCity,
            let uuidPr =  mapPoint?.uuidPartner {
            uuidCity = uuidCt
            uuidPartner = uuidPr
        }

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPartnerDetail"),
                                        object: nil,
                                        userInfo: ["uuidCity": uuidCity,
                                                   "uuidPartner": uuidPartner])

    }
    
    @objc func officesViewTapped() {
        
    }
}
