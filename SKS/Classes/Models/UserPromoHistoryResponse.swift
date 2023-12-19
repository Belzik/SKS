import Foundation

typealias UserPromoHistoryResponse = [UserPromoHistory]

class UserPromoHistory: Codable {
    var codeValue: String
    var validThru: String
    var granted: String
}
