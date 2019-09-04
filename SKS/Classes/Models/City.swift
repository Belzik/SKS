//
//  City.swift
//  SKS
//
//  Created by Александр Катрыч on 01/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

typealias CitiesResponse = [City]

class City: Codable, TypeOfSourcePicker {
    var title: String {
        get {
            return nameCity ?? ""
        }
    }
    
    let uuidCity: String?
    let nameCity: String?
    let count: Int?
    let idPartnerCity: Int?
    let salePoints: [SalePoint]?
    
    enum CodingKeys: String, CodingKey {
        case uuidCity
        case nameCity
        case count
        case idPartnerCity
        case salePoints
    }
}
