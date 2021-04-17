//
//  MapPartnerViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 01/02/2020.
//  Copyright © 2020 Katrych. All rights reserved.
//

import UIKit
import YandexMapKit
import Pulley
import Kingfisher
import CoreLocation

protocol MapPartnerViewControllerDelegate: class {
    func mapPointTapped(uuid: String)
}

class MapPartnerViewController: BaseViewController {
    @IBOutlet weak var mapView: YMKMapView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var myLocationButton: UIButton!
    @IBOutlet weak var backButtonPlace: UIButton!
    
    @IBOutlet weak var salePointView: UIView!
    @IBOutlet weak var salePointTitleLabel: UILabel!
    
    @IBAction func backButtonPlaceTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func salePointBackButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func myLocationButtonTapped(_ sender: UIButton) {
        locationManager.requestSingleUpdate(withLocationListener: self)
    }
    
    @IBAction func zoom(_ sender: UIButton) {
        let zoomStep: Float = sender.tag == 0 ? -1 : 1
    
        let position = YMKCameraPosition(target: mapView.mapWindow.map.cameraPosition.target,
                                         zoom: mapView.mapWindow.map.cameraPosition.zoom + zoomStep,
                                         azimuth: 0,
                                         tilt: 0)
        
        mapView.mapWindow.map.move(with: position,
                                   animationType: .init(type: .smooth,
                                                        duration: 0.2),
                                   cameraCallback: nil)
        
        
    }

    var selectedPoint: YMKPlacemarkMapObject?
    let locationManager = YMKMapKit.sharedInstance().createLocationManager()
    var locManager = CLLocationManager()
    
    var salePoint: SalePoint?
    
    var salePoints: [SalePoint]?
    var partner: Partner?
    var salePointsObjects: [YMKPlacemarkMapObject] = []
    
    var delegate: MapPartnerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mapObjects = mapView.mapWindow.map.mapObjects
        mapObjects.addTapListener(with: self)
        
        setupNotificationCenter()
        setupMap()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewWillAppear(animated)
    }
    
    func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideMapPointClose), name: NSNotification.Name(rawValue: "hideMapPointClose"), object: nil)
    }
    
    @objc func hideMapPointClose() {
        selectedPoint?.setIconWith(UIImage(named: "SearchResult")!)
        selectedPoint = nil
    }
    
    func setupSalePoints() {
        if let salePoint = self.salePoint {
            showSalePoint(salePoint: salePoint)
        } else if let salePoints = self.salePoints,
            let partner = self.partner  {
            showSalePoints(salePoints: salePoints, partner: partner)
        }
    }
    
    func setupMap() {
        mapView.mapWindow.map.move(with: YMKCameraPosition.init(target: YMKPoint(latitude: 61.785017,
                                                                                 longitude: 34.346878),
                                                                zoom: 14,
                                                                azimuth: 0,
                                                                tilt:0),
                                   animationType: .init(type: .smooth,
                                                        duration: 0),
                                   cameraCallback: nil)
        
        mapView.mapWindow.map.isRotateGesturesEnabled = false

        locManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() == true {
           if CLLocationManager.authorizationStatus() == .restricted ||
            CLLocationManager.authorizationStatus() == .denied ||
            CLLocationManager.authorizationStatus() == .notDetermined {

            addedUserLocation()
           } else {
                addedUserLocation()
            }
       }
    }
    
    func addedUserLocation() {
        let mapKit = YMKMapKit.sharedInstance()
        let userLocationLayer = mapKit.createUserLocationLayer(with: mapView.mapWindow)

        userLocationLayer.setVisibleWithOn(true)
        userLocationLayer.isHeadingEnabled = false
        userLocationLayer.setObjectListenerWith(self)
    }
    
    func setupUI() {
        salePointView.setupShadow(8,
                                  shadowRadius: 8,
                                  color: UIColor.black.withAlphaComponent(0.35),
                                  offset: CGSize(width: 0, height: 0),
                                  opacity: 0.3)
        
        plusButton.setupRoundeShadow()
        minusButton.setupRoundeShadow()
        myLocationButton.setupRoundeShadow()
    }
    
    func showSalePoint(salePoint: SalePoint) {
        if let lat = salePoint.latitude,
            let lon = salePoint.longitude,
            let latitude = Double(lat),
            let longitude = Double(lon) {
            
            var logoString = ""
            if let logo = partner?.logo,
                logo != "" {
                logoString = logo
            } else if let logoIllustrate = partner?.category?.illustrate {
                logoString = NetworkManager.shared.baseURI + logoIllustrate
            }
    
            let mapObjects = mapView.mapWindow.map.mapObjects
            
            let view = SelectedPointView(frame: CGRect.init(x: 0, y: 0, width: 36, height: 88))
            view.isOpaque = false
            view.backgroundColor = UIColor.clear.withAlphaComponent(0.0)
            
            let point = YMKPoint(latitude: latitude,
                                 longitude: longitude)
            
            if let url = URL(string: logoString) {
                view.logoImage.kf.setImage(with: url) { (_, _) in
                    if let yrtView = YRTViewProvider.init(uiView: view) {
                        mapObjects.addPlacemark(with: point, view: yrtView)
                    }
                }
            }
            
            self.pulleyViewController?.setDrawerPosition(position: .partiallyRevealed, animated: true)
            
            mapView.mapWindow.map.move(with: YMKCameraPosition.init(target: point,
                                                        zoom: 18,
                                                        azimuth: 0,
                                                        tilt:0),
                           animationType: .init(type: .smooth,
                                                duration: 0),
                           cameraCallback: nil)
            
            backButtonPlace.isHidden = false
        }
    }
    
    func showSalePoints(salePoints: [SalePoint], partner: Partner) {
        let mapObjects = mapView.mapWindow.map.mapObjects
        
        for salePoint in salePoints {
            if let ltd = salePoint.latitude,
                let lng = salePoint.longitude,
                let latitude = Double(ltd),
                let longitude = Double(lng) {
                
                let point = YMKPoint(latitude: latitude, longitude: longitude)
                
                let mapObject = mapObjects.addPlacemark(with: point,
                                                        image: UIImage(named: "SearchResult")!,
                                                        style: YMKIconStyle.init())
                if let uuid = salePoint.uuidSalePoint {
                    mapObject.userData = uuid
                }
                
                self.salePointsObjects.append(mapObject)
            }
        }
        
        if let boundingBox = getCoordForBounds(salePoints: salePoints) {
            let position = mapView.mapWindow.map.cameraPosition(with: boundingBox)
            
            mapView.mapWindow.map.move(with: position,
                                       animationType: .init(type: .smooth,
                                                    duration: 0.4),
                                       cameraCallback: nil)
        }
        
        salePointTitleLabel.text = partner.name
        salePointView.isHidden = false
    }
    
    func getCoordForBounds(salePoints: [SalePoint]) -> YMKBoundingBox? {
        var arrayOfLatitude: [Double] = []
        var arrayOfLongitude: [Double] = []
        
        for salePoint in salePoints {
            if let ltd = salePoint.latitude,
                let lng = salePoint.longitude,
                let latitude = Double(ltd),
                let longitude = Double(lng) {
                arrayOfLatitude.append(latitude)
                arrayOfLongitude.append(longitude)
            }

        }

        if let minLat = arrayOfLatitude.min(),
            let minLong = arrayOfLongitude.min(),
            let maxLat = arrayOfLatitude.max(),
            let maxLong = arrayOfLongitude.max() {
            
            let southWest = YMKPoint(latitude: minLat, longitude: minLong)
            let northEast = YMKPoint(latitude: maxLat, longitude: maxLong)
            
            return YMKBoundingBox(southWest: southWest, northEast: northEast)
        }
        return nil
    }
    
    func showPartner(mapPartner: MapPartner) {
        let salePoint = salePointsObjects.first { object -> Bool in
            if let uuid = object.userData as? String,
                let uuidSalePoint = mapPartner.point?.uuidSalePoint {
                return uuid == uuidSalePoint
            }
            
            return false
        }
        
        selectedPoint?.setIconWith(UIImage(named: "SearchResult")!)
        
        let view = SelectedPointView(frame: CGRect.init(x: 0, y: 0, width: 36, height: 88))
        view.isOpaque = false
        view.backgroundColor = UIColor.clear.withAlphaComponent(0.0)
        
        if let logo = mapPartner.logo,
            logo != "",
            let url = URL(string: NetworkManager.shared.baseURI + logo) {
            view.logoImage.kf.setImage(with: url) { (_, _) in
                if let yrtView = YRTViewProvider.init(uiView: view) {
                    salePoint?.setViewWithView(yrtView)
                    salePoint?.zIndex = 1
                }
            }
        }
        
        selectedPoint = salePoint
        
        if let lat = mapPartner.point?.latitude,
            let lon = mapPartner.point?.longitude,
            let latitude = Double(lat),
            let longitude = Double(lon) {
            mapView.mapWindow.map.move(with: YMKCameraPosition.init(target: YMKPoint(latitude: latitude,
                                                                                     longitude: longitude),
                                                        zoom: 18,
                                                        azimuth: 0,
                                                        tilt:0),
                           animationType: .init(type: .smooth,
                                                duration: 0.5),
                           cameraCallback: nil)
        }
    }
}

extension MapPartnerViewController: YMKLocationDelegate {
    func onLocationUpdated(with location: YMKLocation) {
        let position = YMKCameraPosition(target: location.position, zoom: 14, azimuth: 0, tilt: 0)
        
        mapView.mapWindow.map.move(with: position,
                                    animationType: .init(type: .smooth,
                                                         duration: 0.4),
                                    cameraCallback: nil)
    }
    
    func onLocationStatusUpdated(with status: YMKLocationStatus) {
        
    }
}

extension MapPartnerViewController: YMKUserLocationObjectListener {
    func onObjectAdded(with view: YMKUserLocationView) {
        view.arrow.setIconWith(UIImage(named:"UserResult")!)
        
        let pinPlacemark = view.pin.useCompositeIcon()

        pinPlacemark.setIconWithName(
            "pin",
            image: UIImage(named:"UserResult")!,
            style:YMKIconStyle(
                anchor: CGPoint(x: 0.5, y: 0.5) as NSValue,
                rotationType: YMKRotationType.rotate.rawValue as NSNumber,
                zIndex: 1,
                flat: true,
                visible: true,
                scale: 1,
                tappableArea: nil))

        view.accuracyCircle.fillColor = UIColor.clear
    }
    
    func onObjectRemoved(with view: YMKUserLocationView) {
        
    }
    
    func onObjectUpdated(with view: YMKUserLocationView, event: YMKObjectEvent) {
        
    }
}

extension MapPartnerViewController: YMKMapObjectTapListener {
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let tPoint = mapObject as? YMKPlacemarkMapObject else {
             return true
        }
        
        selectedPoint?.setIconWith(UIImage(named: "SearchResult")!)
        
        mapView.mapWindow.map.move(with: YMKCameraPosition.init(target: tPoint.geometry,
                                     zoom: 18,
                                     azimuth: 0,
                                     tilt:0),
        animationType: .init(type: .smooth,
                             duration: 0.5),
        cameraCallback: nil)
        
        if let data = tPoint.userData as? String {
            let view = SelectedPointView(frame: CGRect.init(x: 0, y: 0, width: 36, height: 88))
            view.isOpaque = false
            view.backgroundColor = UIColor.clear.withAlphaComponent(0.0)
            
            var logoString = ""
            if let logo = partner?.logo,
                logo != "" {
                logoString = logo
            } else if let logoIllustrate = partner?.category?.illustrate {
                logoString = NetworkManager.shared.baseURI + logoIllustrate
            }
            
            if let url = URL(string: logoString) {
                view.logoImage.kf.setImage(with: url) { (_, _) in
                    if let yrtView = YRTViewProvider.init(uiView: view) {
                        tPoint.setViewWithView(yrtView)
                        tPoint.zIndex = 1
                    }
                }
            }
            
            self.pulleyViewController?.setDrawerPosition(position: .partiallyRevealed, animated: true)
            
            delegate?.mapPointTapped(uuid: data)
        }
        selectedPoint = tPoint
        
        return true
    }
}
