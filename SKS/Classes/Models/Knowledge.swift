import Foundation

struct KnowledgeResponse: Codable {
    var data: [Question]?
}

struct Question: Codable {
    var uuidQuestion: String?
    var uuidUniversity: String?
    var shortNameUniversity: String?
    var question: String?
    var answer: String?
    var user_voted: Bool?
    var files: [QuestionFile]?
}

extension Question: KnowledgeTableViewCellSource {
    var pict: String? {
        nil
    }

    var title: String {
        return question ?? ""
    }
}

struct QuestionFile: Codable {
    var uuidFile: String?
    var fileName: String?
    var s3Link: String?
    var fileSize: Int?
    var fileExtension: String?
}


struct Vote: Codable {
    var uuidUser: String?
}
