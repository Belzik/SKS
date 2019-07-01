//
//  City.swift
//  SKS
//
//  Created by Александр Катрыч on 01/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

struct City {
    var id: Int
    var code: String
    var name: String
    
    init?(dictionary: [String: AnyObject]) {
        guard let id = dictionary["id"] as? Int,
                let code = dictionary["code"] as? String,
                let name = dictionary["name"] as? String else { return nil }
        
        self.id = id
        self.code = code
        self.name = name
    }
}
