//
//  Discount.swift
//  SKS
//
//  Created by Александр Катрыч on 02/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

// MARK: - Discount
class Discount: Codable {
    let idDiscount: Int?
    let createdAt: String?
    let updatedAt: String?
    let idPartner: Int?
    let name: String?
    let discountDescription: String?
    let size: Int?
    let type: String?
    
    enum CodingKeys: String, CodingKey {
        case idDiscount
        case createdAt
        case updatedAt
        case idPartner
        case name
        case discountDescription = "description"
        case size
        case type
    }
}

