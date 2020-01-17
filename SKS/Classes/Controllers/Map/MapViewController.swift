//
//  MapViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 06/11/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit
import Pulley
import YandexMapKit
import CoreLocation

class MapViewController: BaseViewController {
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var routeButton: UIButton!
    @IBOutlet weak var mapView: YMKMapView!
    @IBOutlet weak var backButtonPlace: UIButton!
    
    var timer: Timer = Timer.init()
    let locationManager = YMKMapKit.sharedInstance()!.createLocationManager()
    var collection: YMKClusterizedPlacemarkCollection?
    private let FONT_SIZE: CGFloat = 15
    private let MARGIN_SIZE: CGFloat = 3
    private let STROKE_SIZE: CGFloat = 3
    var locManager = CLLocationManager()
    
    var pointsOfPartners: [MapPoint] = []
    var uuidCategory = ""
    
    var isForLoadingPoints: Bool = false
    var latUser = ""
    var lngUser = ""
    
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        
        self.pulleyViewController?.performSegue(withIdentifier: "segueFilter", sender: uuidCategory)
    }
    
    @IBAction func backButtonPlaceTapped(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hideMapPoint"),
                                        object: nil,
                                        userInfo: nil)
        
        searchView.isHidden = false
        filterButton.isHidden = false
        backButtonPlace.isHidden = true
    }
    
    @IBAction func zoom(_ sender: UIButton) {
        let zoomStep: Float = sender.tag == 0 ? -1 : 1
        //collection?.clear() очистить коллекцию
        let position = YMKCameraPosition(target: mapView.mapWindow.map.cameraPosition.target,
                                         zoom: mapView.mapWindow.map.cameraPosition.zoom + zoomStep,
                                         azimuth: 0,
                                         tilt: 0)
        
        mapView.mapWindow.map.move(with: position,
                                   animationType: .init(type: .smooth,
                                                        duration: 0.2),
                                   cameraCallback: nil)
        
        
    }
    
    @IBAction func userPosition(_ sender: UIButton) {
        locationManager.requestSingleUpdate(withLocationListener: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocManager()
        collection = mapView.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
        collection?.addTapListener(with: self)
        
        
        mapView.mapWindow.map.addCameraListener(with: self)
        
        setupNotificationCenter()
        setupMap()
        setupUI()
    }
    
//    func setupNotificationCenter() {
//
//    }
    

    
    func setupLocManager() {
        if CLLocationManager.locationServicesEnabled() {
            locManager.requestAlwaysAuthorization()
            locManager.requestWhenInUseAuthorization()
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyBest
            locManager.startUpdatingLocation()
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
        
        mapView.mapWindow.map.setMapLoadedListenerWith(self)
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
        let mapKit = YMKMapKit.sharedInstance()!
        let userLocationLayer = mapKit.createUserLocationLayer(with: mapView.mapWindow)

        userLocationLayer.setVisibleWithOn(true)
        userLocationLayer.isHeadingEnabled = false
        userLocationLayer.setObjectListenerWith(self)
        
        locationManager.requestSingleUpdate(withLocationListener: self)
    }
    
    func setupUI() {
        searchView.setupShadow(8,
                               shadowRadius: 8,
                               color: UIColor.black.withAlphaComponent(0.35),
                               offset: CGSize(width: 0, height: 0),
                               opacity: 0.3)
        
        filterButton.setupShadow(8,
                                 shadowRadius: 8,
                                 color: UIColor.black.withAlphaComponent(0.35),
                                 offset: CGSize(width: 0, height: 0),
                                 opacity: 0.3)
        
        plusButton.setupRoundeShadow()
        minusButton.setupRoundeShadow()
        routeButton.setupRoundeShadow()
    }
    
    func getPoints() {
        let rightTopPoint = mapView.mapWindow.map.visibleRegion.topRight
        let leftBottomPoint = mapView.mapWindow.map.visibleRegion.bottomLeft
            
        //isLoadedPoints = true
        NetworkManager.shared.getPoints(topRightCornerLatitude: String(rightTopPoint.latitude),
                                        topRightCornerLongitude: String(rightTopPoint.longitude),
                                        lowerLeftCornerLatitude: String(leftBottomPoint.latitude),
                                        lowerLeftCornerLongitude: String(leftBottomPoint.longitude),
                                        uuidCategory: self.uuidCategory,
                                        latUser: latUser,
                                        lngUser: lngUser) { [weak self] result in
            
            DispatchQueue.global(qos: .background).async {
                if let resultPoints = result.result.value,
                    var pointsOfPartners = self?.pointsOfPartners {
                    var points: [YMKPoint] = []
                    
                    for point in resultPoints {
                        if let longitude = point.longitude,
                            let latitude = point.latitude {
                                if let longitude = Double(longitude),
                                    let latitude = Double(latitude) {
                                    if !pointsOfPartners.contains(point) {
                                        points.append(YMKPoint.init(latitude: latitude,
                                                                    longitude: longitude))
                                        self?.pointsOfPartners.append(point)
                                        pointsOfPartners.append(point)
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                                            let placemark = self?.collection?.addPlacemark(with: YMKPoint.init(latitude: latitude,
                                                                                                           longitude: longitude),
                                                                                       image: UIImage(named: "SearchResult")!,
                                                                                       style: YMKIconStyle.init())
                                            
                                            placemark?.userData = point
                                            
                                        })
                                    }
                                }
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                        if let collection = self?.collection {
                            if points.count > 0 {
                                collection.clusterPlacemarks(withClusterRadius: 60, minZoom: 15)
                            }
                        }
                        //self?.isLoadedPoints = false
                    })
                }
            }

        }
    }
    
    func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleCategory), name: NSNotification.Name(rawValue: "changeCategory"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handlePoint), name: NSNotification.Name(rawValue: "showMapPoint"), object: nil)
    }
    
    @objc func handleCategory(_ notification: NSNotification) {
        if let uuidCategory = notification.userInfo?["uuidCategory"] as? String {
            if uuidCategory == "" {
                filterButton.setImage(UIImage(named: "ic_filter"), for: .normal)
            } else {
                filterButton.setImage(UIImage(named: "ic_filter_on"), for: .normal)
            }
            
            self.uuidCategory = uuidCategory
            collection?.clear()
            pointsOfPartners.removeAll()
            getPoints()
        }
    }
    
    @objc func handlePoint(_ notification: NSNotification) {
        if let mapPartner = notification.userInfo?["mapPoint"] as? MapPartner {
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
                
                searchView.isHidden = true
                filterButton.isHidden = true
                backButtonPlace.isHidden = false
            }
        }
    }

}

extension MapViewController: YMKUserLocationObjectListener {
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

extension MapViewController: YMKMapLoadedListener {
    func onMapLoaded(with statistics: YMKMapLoadStatistics) {
        
    }
}

extension MapViewController: YMKLocationDelegate {
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

extension MapViewController: YMKClusterListener, YMKClusterTapListener {
    func onClusterAdded(with cluster: YMKCluster) {
        cluster.appearance.setIconWith(clusterImage(cluster.size))
        cluster.addClusterTapListener(with: self)
    }
    
    func onClusterTap(with cluster: YMKCluster) -> Bool {
        mapView.mapWindow.map.move(with: YMKCameraPosition.init(target: YMKPoint(latitude: cluster.appearance.geometry.latitude,
                                                                         longitude: cluster.appearance.geometry.longitude),
                                                        zoom: mapView.mapWindow.map.cameraPosition.zoom + 1,
                                                        azimuth: 0,
                                                        tilt:0),
                           animationType: .init(type: .smooth,
                                                duration: 0.2),
                           cameraCallback: nil)

        
        return true
    }
    
    func clusterImage(_ clusterSize: UInt) -> UIImage {
        let scale = UIScreen.main.scale
        let text = (clusterSize as NSNumber).stringValue
        let font = UIFont.systemFont(ofSize: FONT_SIZE * scale)
        let size = text.size(withAttributes: [NSAttributedString.Key.font: font])
        let textRadius = sqrt(size.height * size.height + size.width * size.width) / 2
        let internalRadius = textRadius + MARGIN_SIZE * scale
        let externalRadius = internalRadius + STROKE_SIZE * scale
        let iconSize = CGSize(width: externalRadius * 2, height: externalRadius * 2)

        UIGraphicsBeginImageContext(iconSize)
        let ctx = UIGraphicsGetCurrentContext()!

        ctx.setFillColor(ColorManager.green.value.cgColor)
        ctx.fillEllipse(in: CGRect(
            origin: .zero,
            size: CGSize(width: 2 * externalRadius, height: 2 * externalRadius)));

        ctx.setFillColor(UIColor.white.cgColor)
        ctx.fillEllipse(in: CGRect(
            origin: CGPoint(x: externalRadius - internalRadius, y: externalRadius - internalRadius),
            size: CGSize(width: 2 * internalRadius, height: 2 * internalRadius)));

        (text as NSString).draw(
            in: CGRect(
                origin: CGPoint(x: externalRadius - size.width / 2, y: externalRadius - size.height / 2),
                size: size),
            withAttributes: [
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: UIColor.black])
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        return image
    }
}

extension MapViewController: YMKMapCameraListener {
    func onCameraPositionChanged(with map: YMKMap, cameraPosition: YMKCameraPosition, cameraUpdateSource: YMKCameraUpdateSource, finished: Bool) {
        
        runTimer()
    }
    
    func runTimer() {
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [unowned self] timer in
            self.getPoints()
        }
    }
}

extension PulleyViewController {
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFilter",
            let uuidCategory = sender as? String {
            let dvc = segue.destination as! CategoriesViewController
            dvc.uuidCategory = uuidCategory
        }
    }
}

extension MapViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        
        return true
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        let long = userLocation.coordinate.longitude;
        let lat = userLocation.coordinate.latitude;

        latUser = String(lat)
        lngUser = String(long)
    }
}

extension MapViewController: YMKMapObjectTapListener {
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let tPoint = mapObject as? YMKPlacemarkMapObject else {
             return true
        }
        
        mapView.mapWindow.map.move(with: YMKCameraPosition.init(target: tPoint.geometry,
                                    zoom: 18,
                                    azimuth: 0,
                                    tilt:0),
       animationType: .init(type: .smooth,
                            duration: 0.5),
       cameraCallback: nil)
        
        searchView.isHidden = true
        filterButton.isHidden = true
        backButtonPlace.isHidden = false
        
        if let point = tPoint.userData as? MapPoint {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showMapPointMap"),
                                            object: nil,
                                            userInfo: ["point": point])
        }
        
        return true
    }
    
    
}
