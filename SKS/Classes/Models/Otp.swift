//
//  Otp.swift
//  SKS
//
//  Created by Александр Катрыч on 15/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

class OtpResponse: Codable {
    let tokens: Tokens?
    let status: String?
    let uniqueSess: String?
}

class Tokens: Codable {
    let accessToken: String?
    let refreshToken: String?
}
