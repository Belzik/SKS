//
//  AddToFavoriteResponse.swift
//  SKS
//
//  Created by Александр Катрыч on 31.03.2021.
//  Copyright © 2021 Katrych. All rights reserved.
//

import Foundation

class AddToFavoriteResponse: Codable {
    let status: Bool?
    let wasProcessedEarlier: Bool?
}
