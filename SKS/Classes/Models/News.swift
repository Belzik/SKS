//
//  News.swift
//  SKS
//
//  Created by Alexander on 04/12/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

typealias NewsResponse = [News]

class News: Codable {
    let uuidNews: String?
    let typeNews: String?
    let publishBegin: String?
    let nameRegion: String?
    let uuidUniver: String?
    let title: String?
    let content: String?
    var photoUrl: [String]?
    let event: Event?
    let pooling: Pooling?
}

class Event: Codable {
    let uuidEvent: String?
    let title: String?
    let description: String?
    let date: String?
    let endRegistration: String?
    var placesCount: Int?
    var placesCountBooked: Int?
    let address: String?
    var bookedForMe: Bool?
    var bookedAccess: Bool?
}

class Pooling: Codable {
    let question: String?
    let endPooling: String?
    let uuidPooling: String?
    let answerTypes: [AnswerType]?
    var voted: Bool?
    var voteAccess: Bool?
}

class AnswerType: Codable {
    var title: String?
    var votes: Int?
    var uuidAnswerType: String?
    var voted: Bool?
    var isSelected: Bool = false
    var allVotesCount: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case title
        case votes
        case uuidAnswerType
        case voted
    }
}
