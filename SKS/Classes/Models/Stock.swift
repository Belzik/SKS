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

class StockHome {
    var title: String
    var description: String
    var period: String
    
    init(title: String, description: String, period: String) {
        self.title = title
        self.description = description
        self.period = period
    }
}
