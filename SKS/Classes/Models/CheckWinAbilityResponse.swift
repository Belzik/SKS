import Foundation

class CheckWinAbilityResponse: Codable {
    var totalCodesCount: Int
    var totalCodesRemaining: Int
    var usedCodesCount: Int
    var userCodesUsed: Int
    var userCodeRemaining: Int
    var winAbility: Bool
}
