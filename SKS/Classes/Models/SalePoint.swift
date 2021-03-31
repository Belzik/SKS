//
//  SalePoint.swift
//  SKS
//
//  Created by Александр Катрыч on 09/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

class SalePointsResponse: Codable {
    let points: [SalePoint]?
}

class SalePoint: Codable {
    let idSalePoint: Int?
    let createdAt: String?
    let updatedAt: String?
    let idPartnerCity: Int?
    let address: String?
    let timeWork: [TimeWork]?
    let uuidSalePoint: String?
    let latitude: String?
    let longitude: String?
    let distance: Int?
    let isOpenedNow: Bool?
}
