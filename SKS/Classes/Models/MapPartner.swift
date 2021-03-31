//
//  MapPartner.swift
//  SKS
//
//  Created by Alexander on 13/01/2020.
//  Copyright © 2020 Katrych. All rights reserved.
//
import Foundation

typealias MapPartnerResponse = [MapPartner]

class MapPartner: Codable {
    var uuidPartner: String?
    var logo: String?
    var uuidCategory: String?
    var categoryName: String?
    var rating: String?
    var name: String?
    var legalName: String?
    var description: String?
    var points: [PointPartner]?
    var point: PointPartner?
    
    init(categoryName: String?,
         name: String?,
         rating: String?,
         logo: String?,
         legalName: String?,
         description: String?,
         point: PointPartner?) {
        self.categoryName = categoryName
        self.name = name
        self.rating = rating
        self.logo = logo
        self.legalName = legalName
        self.description = description
        self.point = point
    }
}

class PointPartner: Codable {
    var uuidSalePoint: String?
    var address: String?
    var latitude: String?
    var longitude: String?
    var timeWork: [TimeWork]?
    var distance: Int?
    var uuidCity: String?
    var isOpenedNow: Bool?
    
    init(address: String?,
         latitude: String?,
         longitude: String?,
         timeWork: [TimeWork]?,
         distance: Int?,
         isOpenedNow: Bool?,
         uuidSalePoint: String?) {
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.timeWork = timeWork
        self.distance = distance
        self.isOpenedNow = isOpenedNow
        self.uuidSalePoint = uuidSalePoint
    }
}
