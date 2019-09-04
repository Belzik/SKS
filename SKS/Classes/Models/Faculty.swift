//
//  Faculty.swift
//  SKS
//
//  Created by Александр Катрыч on 24/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

typealias FacultiesResponse = [Faculty]

class Faculty: Codable, TypeOfSourcePicker {
    var title: String {
        get {
            return nameDepartment
        }
    }
    
    let uuidDepartment: String
    let nameDepartment: String
    let type: String?
}
