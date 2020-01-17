//
//  SmsResponse.swift
//  SKS
//
//  Created by Александр Катрыч on 16/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

class SmsResponse: Codable {
    var attempt: String?
    var status: String?
    var loginKey: String?
}

