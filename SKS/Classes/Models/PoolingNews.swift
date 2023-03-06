import Foundation

class PoolingNews: Codable {
    let uuidNews: String?
    let uuidPooling: String?
    let startPooling: String?
    let endPooling: String?
    var voted: Int?
    var isView: Bool?
    let poolingIsActive: Bool?
    let userIsVoted: Bool?
    let questions: [QuestionNew]?

    func makeRequest() -> QuestionRequest? {
        guard let uuidPooling = uuidPooling else { return nil }
        var answers: [AnswerRequest] = []

        if let questions = questions {
            for question in questions {
                var answerUuids: [AnswerUuid] = []

                if let answerVariants = question.answerVariants {
                    for answer in answerVariants {
                        if answer.isVoted {
                            if let uuid = answer.answerVariantUuid {
                                answerUuids.append(AnswerUuid(answerVariantUuid: uuid))
                            }
                        }
                    }
                }

                if let questionUuid = question.questionUuid {
                    let answer = AnswerRequest(
                        questionUuid: questionUuid,
                        otherVariant: question.userAnswerOtherText,
                        selectedAnswers: answerUuids
                    )

                    answers.append(answer)
                }
            }
        }


        let request = QuestionRequest(uuidPooling: uuidPooling, questions: answers)
        return request
    }

    func isAllSelected() -> Bool {
        var selecteds: [Bool] = []

        if let questions = questions {
            for question in questions {
                var isVoted = false
                if let answers = question.answerVariants {
                    for answer in answers {
                        if answer.isVoted {
                            isVoted = true
                        }
                    }
                }
                if question.isUserAnswerOther {
                    isVoted = true
                }
                selecteds.append(isVoted)
            }
        }
        var allSelected = true

        for selected in selecteds {
            if !selected {
                allSelected = false
            }
        }

        return allSelected
    }
}

class QuestionNew: Codable {
    let idPoolingQuestion: Int?
    let idPooling: Int?
    let question: String?
    let questionType: String?
    let questionUuid: String?
    let allowOther: Bool?
    let answerVariants: [AnswerVariant]?
    var userAnswerOther: String?
    var countAllOther: Int?
    var countAll: Int = 0
    var userAnswerOtherText: String = ""
    var isUserAnswerOther: Bool = false

    enum CodingKeys: String, CodingKey {
        case idPoolingQuestion
        case idPooling
        case question
        case questionType
        case questionUuid
        case allowOther
        case answerVariants
        case userAnswerOther
        case countAllOther
    }
}

class AnswerVariant: Codable {
    let answerVariant: String?
    let answerVariantUuid: String?
    var voted: Int?
    let position: String?

    var countAllOther: Int = 0
//    var isVoted: Bool {
//        get {
//            if let voted = voted {
//                return voted == 1 ? true : false
//            } else {
//                return false
//            }
//        }
//
//        set {
//            if newValue {
//                voted = 1
//            } else {
//                voted = 0
//            }
//        }
//    }

    var isVoted: Bool = false

    enum CodingKeys: String, CodingKey {
        case answerVariant
        case answerVariantUuid
        case voted
        case position
    }

    init(answerVariant: String?, voted: Int?) {
        self.answerVariant = answerVariant
        self.voted = voted
        answerVariantUuid = nil
        position = nil
    }
}
