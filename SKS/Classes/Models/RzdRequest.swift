//
//  RzsRequest.swift
//  SKS
//
//  Created by Александр Катрыч on 27.03.2022.
//  Copyright © 2022 Katrych. All rights reserved.
//

import Foundation

enum StatusRequest: String {
    case atWork = "atWork"
    case approved
    case rejected
}

class RzdRequest: Codable {
    var uuid: String?
    var studentRequestId: String?
    var status: String?
    var message: String?
    var updatedAt: String?
    var createdAt: String?

    enum CodingKeys: String, CodingKey {
        case uuid
        case studentRequestId = "student_request_id"
        case status
        case message
        case updatedAt = "updated_at"
        case createdAt = "created_at"
    }
}

extension RzdRequest {
    var statusRequest: StatusRequest {
        return .init(rawValue: status ?? "") ?? .atWork
    }
}
