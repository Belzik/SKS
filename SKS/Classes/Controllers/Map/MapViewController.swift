//
//  MapViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 06/11/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit
import Pulley
import YandexMapsMobile
import CoreLocation
import Kingfisher

class MapViewController: BaseViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var routeButton: UIButton!
    @IBOutlet weak var mapView: YMKMapView!
    @IBOutlet weak var backButtonPlace: UIButton!
    
    @IBOutlet weak var salePointView: UIView!
    @IBOutlet weak var salePointTitleLabel: UILabel!
    
    // MARK: - Properties
    
    var timer: Timer = Timer.init()
    var searchTimer: Timer = Timer.init()
    let locationManager = YMKMapKit.sharedInstance().createLocationManager()
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
    var searchString = ""
    
    var selectedPoint: YMKPlacemarkMapObject?
    
    var selectedPointPartner: YMKPlacemarkMapObject?
    
    var isFromPartner = false
    
    var salePointsObjects: [YMKPlacemarkMapObject] = []
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocManager()
        
        let mapObjects = mapView.mapWindow.map.mapObjects
        collection = mapView.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
        collection?.addTapListener(with: self)
        mapObjects.addTapListener(with: self)
        
        mapView.mapWindow.map.addCameraListener(with: self)
        
        setupNotificationCenter()
        setupMap()
        setupUI()
        setupSearch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewWillAppear(animated)
    }
    
    // MARK: - Methods
    
    func setupSearch() {
        searchTextField.addTarget(self, action: #selector(textFieldDidchange), for: .editingChanged)
    }
    
    @objc func textFieldDidchange() {
        searchString = searchTextField.text!
        runSearchTimer()
    }
    
    func runSearchTimer() {
        searchTimer.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.75, repeats: false) { [weak self] timer in
            self?.collection?.clear()
            self?.pointsOfPartners.removeAll()
            self?.getPoints()
            
            if let searchString = self?.searchString {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeSearchString"),
                                                object: nil,
                                                userInfo: ["searchString": searchString])
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
        let mapKit = YMKMapKit.sharedInstance()
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
        
        salePointView.setupShadow(8,
                                  shadowRadius: 8,
                                  color: UIColor.black.withAlphaComponent(0.35),
                                  offset: CGSize(width: 0, height: 0),
                                  opacity: 0.3)
        
        plusButton.setupRoundeShadow()
        minusButton.setupRoundeShadow()
        routeButton.setupRoundeShadow()
    }
    
    func getPoints() {
        if backButtonPlace.isHidden == false { return }
        if salePointView.isHidden == false { return }
        
        let rightTopPoint = mapView.mapWindow.map.visibleRegion.topRight
        let leftBottomPoint = mapView.mapWindow.map.visibleRegion.bottomLeft
            
        //isLoadedPoints = true
        NetworkManager.shared.getPoints(topRightCornerLatitude: String(rightTopPoint.latitude),
                                        topRightCornerLongitude: String(rightTopPoint.longitude),
                                        lowerLeftCornerLatitude: String(leftBottomPoint.latitude),
                                        lowerLeftCornerLongitude: String(leftBottomPoint.longitude),
                                        uuidCategory: self.uuidCategory,
                                        latUser: latUser,
                                        lngUser: lngUser,
                                        searchString: searchString) { [weak self] result in
            
            DispatchQueue.main.async {
                if let resultPoints = result.value,
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
                                        
                                        let placemark = self?.collection?.addPlacemark(with: YMKPoint.init(latitude: latitude,
                                                                                                       longitude: longitude),
                                                                                   image: UIImage(named: "SearchResult")!,
                                                                                   style: YMKIconStyle.init())

                                        placemark?.userData = point
                                    }
                                }
                        }
                    }
                    
                    if let collection = self?.collection {
                        if points.count > 0 {
                            collection.clusterPlacemarks(withClusterRadius: 60, minZoom: 15)
                        }
                    }
                } else {
                    
                }
            }

        }
    }
    
    func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleCategory), name: NSNotification.Name(rawValue: "changeCategory"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handlePoint), name: NSNotification.Name(rawValue: "showMapPoint"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showPartnerDetail), name: NSNotification.Name(rawValue: "showPartnerDetail"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideMapPointClose), name: NSNotification.Name(rawValue: "hideMapPointClose"), object: nil)
    }
    
    @objc func hideMapPointClose() {
        selectedPointPartner?.setIconWith(UIImage(named: "SearchResult")!)
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
            selectedPoint = nil
            getPoints()
        }
    }
    
    @objc func showPartnerDetail(_ notification: NSNotification) {
        if let uuidCity = notification.userInfo?["uuidCity"] as? String,
            let uuidPartner = notification.userInfo?["uuidPartner"] as? String {
            
            var parentVC = parent
            while parentVC != nil {
                if let dashboardMapViewController = parentVC as? DashboardMapViewController {
                    dashboardMapViewController.performSegue(withIdentifier: "seguePartner",
                                                            sender: (uuidPartner: uuidPartner, uuidCity: uuidCity))
                    break
                }
                parentVC = parentVC?.parent
            }
            
        }
        
        
    }
    
    @objc func handlePoint(_ notification: NSNotification) {
        if salePointView.isHidden {
            if let mapPartner = notification.userInfo?["mapPoint"] as? MapPartner {
                if let lat = mapPartner.point?.latitude,
                    let lon = mapPartner.point?.longitude,
                    let latitude = Double(lat),
                    let longitude = Double(lon) {
                    
                    let mapObjects = mapView.mapWindow.map.mapObjects
                    
                    selectedPoint?.setIconWith(UIImage(named: "SearchResult")!)
                    self.selectedPointPartner = nil
//                    if let selectedPointPartner = selectedPointPartner {
//                        mapObjects.remove(with: selectedPointPartner)
//                        
//                    }
                    let view = SelectedPointView(frame: CGRect.init(x: 0, y: 0, width: 36, height: 88))
                    
                    let point = YMKPoint(latitude: latitude,
                    longitude: longitude)
                    
                    view.isOpaque = false
                    view.backgroundColor = UIColor.clear.withAlphaComponent(0.0)

                    if let logo = mapPartner.logo,
                        logo != "",
                        let url = URL(string: NetworkManager.shared.baseURI + logo) {
                        
                        view.logoImage.kf.setImage(with: url) { [weak self] (_, _) in
                            if let yrtView = YRTViewProvider.init(uiView: view) {
                                let placeMark = mapObjects.addPlacemark(with: point, view: yrtView)
                                placeMark.zIndex = 1
                                
                                self?.selectedPointPartner = placeMark

                            }
                        }
                    }
                    
                    self.pulleyViewController?.setDrawerPosition(position: .partiallyRevealed, animated: true)
                    
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
                    salePointView.isHidden = true
                    backButtonPlace.isHidden = false
                }
            }
        } else {
            if let mapPartner = notification.userInfo?["mapPoint"] as? MapPartner {
                let salePoint = salePointsObjects.first { object -> Bool in
                    if let data = object.userData as? (uuid: String, logo: String),
                        let uuidSalePoint = mapPartner.point?.uuidSalePoint {
                        return data.uuid == uuidSalePoint
                    }
                    
                    return false
                }
                
                selectedPointPartner?.setIconWith(UIImage(named: "SearchResult")!)
                
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
                
                selectedPointPartner = salePoint
                
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

    }

    func showSalePoint(salePoint: SalePoint, logo: String) {
        if let lat = salePoint.latitude,
            let lon = salePoint.longitude,
            let latitude = Double(lat),
            let longitude = Double(lon) {
    
            let mapObjects = mapView.mapWindow.map.mapObjects
            collection?.clear()
            pointsOfPartners.removeAll()
            
            for mapObject in salePointsObjects {
                mapObjects.remove(with: mapObject)
            }
            salePointsObjects.removeAll()
            
            selectedPoint = nil
            
            if !backButtonPlace.isHidden {
                if let selectedPointPartner = selectedPointPartner {
                    mapObjects.remove(with: selectedPointPartner)
                    self.selectedPointPartner = nil
                }
            }
            
            self.selectedPointPartner = nil
//            if let selectedPointPartner = selectedPointPartner {
//                mapObjects.remove(with: selectedPointPartner)
//                self.selectedPointPartner = nil
//            }
            
            let view = SelectedPointView(frame: CGRect.init(x: 0, y: 0, width: 36, height: 88))
            
            if let url = URL.init(string: logo) {
                view.logoImage.kf.setImage(with: url)
            }
            
            let point = YMKPoint(latitude: latitude,
            longitude: longitude)
            
            view.isOpaque = false
            view.backgroundColor = UIColor.clear.withAlphaComponent(0.0)
//            mapObjects.addPlacemark(with: point,
//                                    image: UIImage(named: "ic_selected_point")!)
            if let yrtView = YRTViewProvider.init(uiView: view) {
                
                let placeMark = mapObjects.addPlacemark(with: point, view: yrtView)
                placeMark.zIndex = 1
                //mapObjects.addPlace
                
                selectedPointPartner = placeMark
            }
            
            
            self.pulleyViewController?.setDrawerPosition(position: .partiallyRevealed, animated: true)
            
            mapView.mapWindow.map.move(with: YMKCameraPosition.init(target: point,
                                                        zoom: 18,
                                                        azimuth: 0,
                                                        tilt:0),
                           animationType: .init(type: .smooth,
                                                duration: 0),
                           cameraCallback: nil)
            
            searchView.isHidden = true
            filterButton.isHidden = true
            salePointView.isHidden = true
            backButtonPlace.isHidden = false
        }
    }
    
    func showSalePoints(salePoints: [SalePoint], partner: Partner) {
        if !backButtonPlace.isHidden {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hideMapPoint"),
                                            object: nil,
                                            userInfo: nil)
        }
        
        let mapObjects = mapView.mapWindow.map.mapObjects
        collection?.clear()
        pointsOfPartners.removeAll()
        
        for mapObject in salePointsObjects {
            mapObjects.remove(with: mapObject)
        }
        salePointsObjects.removeAll()
        
        if !backButtonPlace.isHidden {
            if let selectedPointPartner = selectedPointPartner {
                mapObjects.remove(with: selectedPointPartner)
                self.selectedPointPartner = nil
            }
        }

        self.selectedPointPartner = nil
        selectedPoint = nil
        
        for salePoint in salePoints {
            if let ltd = salePoint.latitude,
                let lng = salePoint.longitude,
                let latitude = Double(ltd),
                let longitude = Double(lng) {
                
                let point = YMKPoint(latitude: latitude, longitude: longitude)
                
                let mapObject = mapObjects.addPlacemark(with: point,
                                                        image: UIImage(named: "SearchResult")!,
                                                        style: YMKIconStyle.init())
                if let uuid = salePoint.uuidSalePoint,
                    let illustrate = partner.category?.illustrate {
                    mapObject.userData = (uuid: uuid, logo: illustrate)
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
        searchView.isHidden = true
        filterButton.isHidden = true
        backButtonPlace.isHidden = true
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
    
    // MARK: - Actions
    
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        self.pulleyViewController?.performSegue(withIdentifier: "segueFilter", sender: uuidCategory)
        view.endEditing(false)
    }
    
    @IBAction func backButtonPlaceTapped(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hideMapPoint"),
                                        object: nil,
                                        userInfo: nil)
        
        let mapObjects = mapView.mapWindow.map.mapObjects
        
        selectedPoint?.setIconWith(UIImage(named: "SearchResult")!)
        
        if let selectedPointPartner = selectedPointPartner {
            mapObjects.remove(with: selectedPointPartner)
            //self.selectedPointPartner = nil
        }
        
        searchView.isHidden = false
        filterButton.isHidden = false
        backButtonPlace.isHidden = true
    }
    
    @IBAction func salePointBackButtonTapped(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hideSalePoints"),
                                        object: nil,
                                        userInfo: nil)
        
        let mapObjects = mapView.mapWindow.map.mapObjects
        
        for mapObject in salePointsObjects {
            mapObjects.remove(with: mapObject)
        }
        salePointsObjects.removeAll()
        
        searchView.isHidden = false
        filterButton.isHidden = false
        salePointView.isHidden = true
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
    
}

// MARK: - YMKUserLocationObjectListener

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

// MARK: - YMKMapLoadedListener

extension MapViewController: YMKMapLoadedListener {
    func onMapLoaded(with statistics: YMKMapLoadStatistics) {
        
    }
}

// MARK: - YMKLocationDelegate

extension MapViewController: YMKLocationDelegate {
    func onLocationUpdated(with location: YMKLocation) {
        let position = YMKCameraPosition(target: location.position, zoom: 14, azimuth: 0, tilt: 0)
        
        if !isFromPartner {
            mapView.mapWindow.map.move(with: position,
                                       animationType: .init(type: .smooth,
                                                    duration: 0.4),
                                       cameraCallback: nil)
        }
        
        isFromPartner = false
    }
    
    func onLocationStatusUpdated(with status: YMKLocationStatus) {
        
    }
    
    
}

// MARK: - YMKClusterListener, YMKClusterTapListener

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

// MARK: - YMKMapCameraListener

extension MapViewController: YMKMapCameraListener {
    func onCameraPositionChanged(with map: YMKMap, cameraPosition: YMKCameraPosition, cameraUpdateReason: YMKCameraUpdateReason, finished: Bool) {
        if cameraPosition.zoom > 10.455058 { // Вычисленно эксперементально, оптимальный зум для поиска партнеров
            runTimer()
        }
    }
    
    func runTimer() {
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] timer in
            self?.getPoints()
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
        
        if segue.identifier == "seguePartner",
            let data = sender as? (uuidPartner: String, uuidCity: String) {
            let dvc = segue.destination as! TestViewController
            dvc.uuidPartner = data.uuidPartner
            dvc.uuidCity = data.uuidCity
        }
    }
}

// MARK: - UITextFieldDelegate

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
        
        if salePointView.isHidden {
            self.selectedPointPartner = nil
            selectedPoint?.setIconWith(UIImage(named: "SearchResult")!)
            
            mapView.mapWindow.map.move(with: YMKCameraPosition.init(target: tPoint.geometry,
                                        zoom: 18,
                                        azimuth: 0,
                                        tilt:0),
           animationType: .init(type: .smooth,
                                duration: 0.5),
           cameraCallback: nil)
            
            searchView.isHidden = true
            filterButton.isHidden = true
            salePointView.isHidden = true
            backButtonPlace.isHidden = false
            
            if let pointUser = tPoint.userData as? MapPoint {
                let view = SelectedPointView(frame: CGRect.init(x: 0, y: 0, width: 36, height: 88))
                view.isOpaque = false
                view.backgroundColor = UIColor.clear.withAlphaComponent(0.0)
                
                if let logo = pointUser.logo,
                    logo != "",
                    let url = URL(string: logo) {
                    view.logoImage.kf.setImage(with: url) { (_, _) in
                        if let yrtView = YRTViewProvider.init(uiView: view) {
                            tPoint.setViewWithView(yrtView)
                            tPoint.zIndex = 1
                        }
                    }
                } else if let logoIllustrate = pointUser.illustrate,
                    let url = URL(string: NetworkManager.shared.baseURI + logoIllustrate) {
                    
                    view.logoImage.kf.setImage(with: url) { (_, _) in
                        if let yrtView = YRTViewProvider.init(uiView: view) {
                            tPoint.setViewWithView(yrtView)
                            tPoint.zIndex = 1
                        }
                    }
                }
                
                self.pulleyViewController?.setDrawerPosition(position: .partiallyRevealed, animated: true)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showMapPointMap"),
                                                object: nil,
                                                userInfo: ["point": pointUser])
            }
            selectedPoint = tPoint
        } else {
            selectedPointPartner?.setIconWith(UIImage(named: "SearchResult")!)
            
            mapView.mapWindow.map.move(with: YMKCameraPosition.init(target: tPoint.geometry,
                                         zoom: 18,
                                         azimuth: 0,
                                         tilt:0),
            animationType: .init(type: .smooth,
                                 duration: 0.5),
            cameraCallback: nil)
            
            if let data = tPoint.userData as? (uuid: String, logo: String) {
                let view = SelectedPointView(frame: CGRect.init(x: 0, y: 0, width: 36, height: 88))
                view.isOpaque = false
                view.backgroundColor = UIColor.clear.withAlphaComponent(0.0)
                
                if let url = URL(string: NetworkManager.shared.baseURI + data.logo) {
                    
                    view.logoImage.kf.setImage(with: url) { (_, _) in
                        if let yrtView = YRTViewProvider.init(uiView: view) {
                            tPoint.setViewWithView(yrtView)
                            tPoint.zIndex = 1
                        }
                    }
                }
                
                self.pulleyViewController?.setDrawerPosition(position: .partiallyRevealed, animated: true)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showMapPointSalePoint"),
                                                object: nil,
                                                userInfo: ["uuidSalePoint": data.uuid])
            }
            selectedPointPartner = tPoint
        }
       
        return true
    }
    
    
}
