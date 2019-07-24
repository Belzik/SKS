//
//  Model.swift
//  SKS
//
//  Created by Александр Катрыч on 01/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

typealias CategoriesResponse = [Category]

struct Category: Decodable {
    var idCategory: Int
    var name: String
}

class CategoryHome {
    var title: String
    var image: UIImage
    var color: UIColor
    var isSelect: Bool = false
    
    init(title: String, image: UIImage, color: UIColor) {
        self.title = title
        self.image = image
        self.color = color
    }
}
