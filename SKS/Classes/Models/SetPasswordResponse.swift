//
//  SetPasswordResponse.swift
//  SKS
//
//  Created by Alexander on 09/01/2020.
//  Copyright © 2020 Katrych. All rights reserved.
//

import Foundation

class SetPasswordResponse: Codable {
    let tokens: Tokens?
    let status: String?
    let uniqueSess: String?
    let statusReason: String?
}

class Tokens: Codable {
    let accessToken: String?
    let refreshToken: String?
}
