//
//  Stock.swift
//  SKS
//
//  Created by Александр Катрыч on 01/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

struct Stock {
    var id: Int
    var nameVendor: String
    var name: String
    var durationStart: String
    var durationEnd: String
    var categoryName: String
    
    init?(dictionary: [String: AnyObject]) {
        guard let id = dictionary["id"] as? Int,
                let nameVendor = dictionary["nameVendor"] as? String,
                let name = dictionary["name"] as? String,
                let durationStart = dictionary["durationStart"] as? String,
                let durationEnd = dictionary["durationEnd"] as? String,
                let categoryName = dictionary["categoryName"] as? String else { return nil }
        
        self.id = id
        self.nameVendor = nameVendor
        self.name = name
        self.durationStart = durationStart
        self.durationEnd = durationEnd
        self.categoryName = categoryName
    }
}
