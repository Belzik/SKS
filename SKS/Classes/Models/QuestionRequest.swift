//
//  QuestionRequest.swift
//  SKS
//
//  Created by Александр Катрыч on 01.12.2022.
//  Copyright © 2022 Katrych. All rights reserved.
//

import Foundation

class QuestionRequest: Codable {
    var uuidPooling: String
    var questions: [AnswerRequest]

    init(uuidPooling: String, questions: [AnswerRequest]) {
        self.uuidPooling = uuidPooling
        self.questions = questions
    }
}

class AnswerRequest: Codable {
    var questionUuid: String
    var otherVariant: String?
    var selectedAnswers: [AnswerUuid]

    init(questionUuid: String, otherVariant: String? = nil, selectedAnswers: [AnswerUuid]) {
        self.questionUuid = questionUuid
        self.otherVariant = otherVariant
        self.selectedAnswers = selectedAnswers
    }
}

class AnswerUuid: Codable {
    var answerVariantUuid: String

    init(answerVariantUuid: String) {
        self.answerVariantUuid = answerVariantUuid
    }
}
