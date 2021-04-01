//
//  Model.swift
//  SKS
//
//  Created by Александр Катрыч on 01/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

typealias CategoriesResponse = [Category]

class Category: Codable {
    let idCategory: Int?
    let createdAt: String?
    let updatedAt: String?
    let uuidCategory: String?
    let name: String?
    let pict: String?
    let illustrate: String?
    let hexcolor: String?
    var isSelected: Bool = false
    let illustrateHeader: String?
    
    enum CodingKeys: String, CodingKey {
        case idCategory
        case createdAt
        case updatedAt
        case uuidCategory
        case name
        case pict
        case illustrate
        case hexcolor
        case illustrateHeader
    }
    
    init(uuidCategory: String, name: String, hexcolor: String, illustrate: String) {
        self.uuidCategory = uuidCategory
        self.name = name
        self.hexcolor = hexcolor
        self.illustrate = illustrate
        createdAt = nil
        updatedAt = nil
        idCategory = nil
        pict = nil
        illustrateHeader = nil
    }
}
