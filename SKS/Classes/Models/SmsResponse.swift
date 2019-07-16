//
//  SmsResponse.swift
//  SKS
//
//  Created by Александр Катрыч on 16/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

struct SmsResponse: Decodable {
    var attempt: String
    var sms: Sms
}

struct Sms: Decodable {
    var status: String
    var idSms: String
}
