//
//  Stock.swift
//  SKS
//
//  Created by Александр Катрыч on 01/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

typealias StocksResponse = [Stock]

class Stock: Codable {
    let idStock: Int?
    let createdAt: String?
    let updatedAt: String?
    let idPartner: Int?
    let name: String
    let stockDescription: String
    let dateBegin: String
    let dateEnd: String
    let status: String?
    let uuidStock: String?
    let createtedData: String?
    let partner: Partner?
    let category: Category?
    let cities: [City]?
    
    enum CodingKeys: String, CodingKey {
        case idStock
        case createdAt
        case updatedAt
        case idPartner
        case name
        case stockDescription = "description"
        case dateBegin
        case dateEnd
        case status
        case uuidStock
        case createtedData
        case partner
        case category
        case cities
    }
}
