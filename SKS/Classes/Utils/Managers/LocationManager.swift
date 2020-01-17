//
//  LocationManager.swift
//  SKS
//
//  Created by Alexander on 15/01/2020.
//  Copyright © 2020 Katrych. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager: NSObject {
    static let shared = LocationManager()
    var location: CLLocation?
    let locationManager = CLLocationManager()
    
    private override init() {
        super.init()
        locationManager.delegate = self
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.location = location
        }
    }
}
