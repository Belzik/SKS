//
//  MapPoint.swift
//  SKS
//
//  Created by Alexander on 25/12/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

typealias MapPointsResponse = [MapPoint]

class MapPoint: Codable {
    let uuidSalePoint: String?
    let uuidPartner: String?
    let uuidCategory: String?
    let categoryName: String?
    let name: String?
    let legalName: String?
    let illustrate: String?
    let keyImg: String?
    let address: String?
    let latitude: String?
    let longitude: String?
    let description: String?
    let timework: [TimeWork]?
    let rating: String?
    let distance: Int?
    let logo: String?
    let geo: GeoMapPoint?
    let isOpenedNow: Bool?
    let uuidCity: String?
}

class GeoMapPoint: Codable {
    let latitude: String?
    let longitude: String?
}

class TimeWork: Codable {
    let name: String?
    let startWork: String?
    let endWork: String?
}

extension MapPoint: Hashable {
    static func == (lhs: MapPoint, rhs: MapPoint) -> Bool {
        if let lhsUuid = lhs.uuidSalePoint,
            let rhsUuid = rhs.uuidSalePoint {
            return lhsUuid == rhsUuid
        } else {
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        
    }
}
