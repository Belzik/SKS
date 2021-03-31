//
//  LocationManager.swift
//  SKS
//
//  Created by Alexander on 15/01/2020.
//  Copyright © 2020 Katrych. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager {
    static let shared = LocationManager()
    var location: CLLocation?
    
    private init() {}
}
