//
//  Date.swift
//  SKS
//
//  Created by Александр Катрыч on 08/09/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

extension Date {
    var month: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        return dateFormatter.string(from: self)
    }
    
    var year: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: self)
    }
}
