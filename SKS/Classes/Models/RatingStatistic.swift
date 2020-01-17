//
//  RatingStatistic.swift
//  SKS
//
//  Created by Александр Катрыч on 02/12/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

class RatingStatistic: Codable {
    let one: Int?
    let two: Int?
    let three: Int?
    let four: Int?
    let five: Int?
    let count: Int?
    let userRating: String?
    
    init(one: Int,
         two: Int,
         three: Int,
         four: Int,
         five: Int,
         count: Int,
         userRating: String) {
        self.one = one
        self.two = two
        self.three = three
        self.four = four
        self.five = five
        self.count = count
        self.userRating = userRating
    }
}
