//
//  Float.swift
//  SKS
//
//  Created by Alexander on 17/12/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

extension Float {
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
