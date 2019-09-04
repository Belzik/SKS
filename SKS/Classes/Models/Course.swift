//
//  Course.swift
//  SKS
//
//  Created by Александр Катрыч on 27/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

class Course: TypeOfSourcePicker {
    var title: String
    var value: String
    
    init(title: String, value: String) {
        self.title = title
        self.value = value
    }
}
