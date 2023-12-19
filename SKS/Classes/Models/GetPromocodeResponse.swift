import Foundation

class GetPromocodeResponse: Codable {
    var codeValue: String
    var description: String?
    var validTrue: String?

    enum CodingKeys: String, CodingKey {
        case codeValue = "code_value"
        case description
        case validTrue = "valid_true"
    }
}
