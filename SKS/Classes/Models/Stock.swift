//
//  Stock.swift
//  SKS
//
//  Created by Александр Катрыч on 01/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

typealias StocksResponse = [Stock]

struct Stock: Decodable {
    var idStock: Int
    var nameVendor: String
    var name: String
    var durationStart: String
    var durationEnd: String
    var categoryName: String
}
