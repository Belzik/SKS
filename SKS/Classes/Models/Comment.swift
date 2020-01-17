//
//  Comment.swift
//  SKS
//
//  Created by Александр Катрыч on 02/12/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

typealias CommentResponse = [Comment]

class Comment: Codable {
    let commentInfo: CommentInfo?
    let userCommentInfo: UserCommentInfo?
    var userLike: String?
}

class CommentInfo: Codable {
    let uuidComment: String?
    let uuidUser: String?
    let uuidPartner: String?
    let comment: String?
    var likes: Int?
    let createdAt: String?
}

class UserCommentInfo: Codable {
    let name: String?
    let photo: String?
    let surname: String?
    let patronymic: String?
}
