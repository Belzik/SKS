//
//  SocialNetwork.swift
//  SKS
//
//  Created by Александр Катрыч on 09/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

// MARK: - SocialNetwork
struct SocialNetwork: Codable {
    let idSocialNetwork: Int?
    let createdAt: String?
    let updatedAt: String?
    let idPartner: Int?
    let type: String
    let link: String?
    let profileName: String?
}
