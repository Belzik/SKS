//
//  Partner.swift
//  SKS
//
//  Created by Александр Катрыч on 02/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

typealias PartnersResponse = [Partner]

struct Partner: Decodable {
    let idPartner: Int
    let name: String
    let cities: CitiesResponse
    let category: Category
    let description: String
    let bigestStock: BigestStock?
    let stocks: [Stock]?
    let discounts: [Discount]?
}
