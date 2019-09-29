//
//  TokensResponse.swift
//  SKS
//
//  Created by Александр Катрыч on 11/09/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

class TokensResponse: Codable {
    let accessToken: String?
    let refreshToken: String?
}
