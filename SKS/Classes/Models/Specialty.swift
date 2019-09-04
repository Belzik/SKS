//
//  Specialty.swift
//  SKS
//
//  Created by Александр Катрыч on 27/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

typealias SpecialtiesResponse = [Specialty]

class Specialty: Codable, TypeOfSourcePicker {
    var title: String {
        get {
            return nameSpecialty
        }
    }
    
    let uuidSpecialty: String
    let nameSpecialty: String
}
