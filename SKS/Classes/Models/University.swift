//
//  Univer.swift
//  SKS
//
//  Created by Александр Катрыч on 24/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

typealias UniversitiesResponse = [University]

class University: Codable, TypeOfSourcePicker {
    var title: String {
        get {
            return shortName ?? nameUniver
        }
    }
    
    let uuidUniver: String
    let nameUniver: String
    let shortName: String?
}

