//
//  Model.swift
//  SKS
//
//  Created by Александр Катрыч on 01/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

typealias CategoriesResponse = [Category]

struct Category: Decodable {
    var idCategory: Int
    var name: String
}
