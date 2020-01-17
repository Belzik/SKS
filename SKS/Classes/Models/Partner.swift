//
//  Partner.swift
//  SKS
//
//  Created by Александр Катрыч on 02/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

typealias PartnersResponse = [Partner]

// MARK: - Partner
class Partner: Codable {
    let uuidPartner: String?
    let name: String?
    let createtedData: String?
    let partnerDescription: String?
    let legalName: String?
    let inn: String?
    let phone: String?
    let email: String?
    let status: String?
    let uuidMainCity: String?
    let nameMainCity: String?
    let discounts: [Discount]?
    let stocks: [Stock]?
    let socialNetworks: [SocialNetwork]?
    let cities: [City]?
    let category: Category?
    let illustrate: String?
    let illustrateHeader: String?
    let rating: String?
    let logo: String?
    let headerPictures: [String]?
    
    enum CodingKeys: String, CodingKey {
        case uuidPartner
        case name
        case createtedData
        case partnerDescription = "description"
        case legalName
        case inn
        case phone
        case email
        case status
        case uuidMainCity
        case nameMainCity
        case discounts
        case stocks
        case socialNetworks
        case cities
        case category
        case illustrate
        case illustrateHeader
        case rating
        case logo
        case headerPictures
    }
}

extension Partner: SearchTableViewCellType {
    var icon: String {
        get {
            return illustrate ?? ""
        }
    }
    
    var title: String {
        get {
            return name ?? ""
        }
    }
    
    var description: String {
        get {
            return partnerDescription ?? ""
        }
    }
    
    var uuid: String {
        get {
            return uuidPartner ?? ""
        }
    }
    
    var type: TypeOfSearchCell {
        get {
            return TypeOfSearchCell.partner
        }
    }
}













