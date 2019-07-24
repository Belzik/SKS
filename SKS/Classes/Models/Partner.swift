//
//  Partner.swift
//  SKS
//
//  Created by Александр Катрыч on 02/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

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

class PartnerHome {
    let title: String
    let description: String
    let image: UIImage
    let discount: String
    let category: String
    let isStock: Bool
    
    init(title: String, description: String, image: UIImage, discount: String, category: String, isStock: Bool) {
        self.title = title
        self.description = description
        self.image = image
        self.discount = discount
        self.category = category
        self.isStock = isStock
    }
}
