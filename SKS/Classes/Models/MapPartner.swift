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
    var legalName: String?
    var description: String?
    var points: [PointPartner]?
    var point: PointPartner?
}

class PointPartner: Codable {
    var uuidSalePoint: String?
    var address: String?
    var latitude: String?
    var longitude: String?
    var timeWork: [TimeWork]?
    var distance: Int?
}
