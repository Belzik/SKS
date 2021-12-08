import Foundation

struct KnowledgesResponse: Codable {
    var data: [Knowledge]?
}

struct Knowledge: Codable {
    var name: String?
    let pict: String?
    var uuidCategory: String?
}

extension Knowledge: KnowledgeTableViewCellSource {
    var title: String {
        return name ?? ""
    }
}
