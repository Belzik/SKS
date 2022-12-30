import Foundation

struct PromoRequest: Codable {
    let uniqueSess: String
    let name: String
    let patronymic: String
    let surname: String
    let birthdate: String
    let keyPhoto: String
    let nameCity: String
    let nameUniversity: String
}
