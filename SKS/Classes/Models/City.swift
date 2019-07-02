//
//  City.swift
//  SKS
//
//  Created by Александр Катрыч on 01/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

typealias CitiesResponse = [City]

struct City: Decodable {
    var idCity: Int
    var code: String
    var name: String
}
