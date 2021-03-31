//
//  AuthVKResponse.swift
//  SKS
//
//  Created by Alexander on 23/01/2020.
//  Copyright © 2020 Katrych. All rights reserved.
//

import Foundation

class AuthVKResponse: Codable {
    var tokens: Tokens?
    var status: String?
    var statusReason: String?
    var uniqueSess: String?
    var possibleData: PossibleData?
}

class PossibleData: Codable {
    var name: String?
    var surname: String?
    var birthdate: String?
}
