//
//  Discount.swift
//  SKS
//
//  Created by Александр Катрыч on 02/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

struct Discount: Decodable {
    let idDiscount: Int
    let name: String
    let description: String
    let size: Int
}
