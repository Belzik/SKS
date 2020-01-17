//
//  Otp.swift
//  SKS
//
//  Created by Александр Катрыч on 15/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

class OtpResponse: Codable {
    var status: String?
    var statusReason: String?
    var setPasswordKey: String?
}
