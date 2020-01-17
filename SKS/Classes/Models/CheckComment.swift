//
//  CheckComment.swift
//  SKS
//
//  Created by Alexander on 14/01/2020.
//  Copyright © 2020 Katrych. All rights reserved.
//

import Foundation

class CheckComment: Codable {
    var info: InfoCheckComment?
    var status: String?
    var rating: Int?
}

class InfoCheckComment: Codable {
    var uuidComment: String?
    var comment: String?
}
