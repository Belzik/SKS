import Foundation
import SwiftyRSA

struct RSAData {
    let key: String
    let verifyKey: String
}

final class RSAService {
    // MARK: Properties

    static let shared = RSAService()
    private let publicKey =
    """
    MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyKm/ABhMV2QOwyE4bxsi
    er174K3xOzoCLCG0LSRdZ3NcH9QzTOnSci5KyHwrE28t+Fl4TDQl/n4wUePZEeWn
    zeUUoxgSqKoJpREeg8oQMt98EHzbwh7Jd0LwY9XAeGizSFa3e19MANZtNffJbH9G
    D0/ywB2S+tdlaS0CDYs9Ko8cQb7eBhW5HHMcRpRFw2TBgWkARkx3q55/Xc/9uryQ
    fvrJhg2BAX3MTUY+cQDUOHAkmKEKKDElNxmrKvHy7VITianScMqG+FRMI++sVOid
    KnY6SlCOlGmCpUPdo5tBrrV72s108Mw6Fve2TuFE9aSFnxQHnMYtVBJxOdEQuU7e
    UQIDAQAB
    """

    // MARK: - Initialization

    private init() {}

    // MARK: - Methods

    func generateAnEncryptedString() -> RSAData {
        let str = UUID().uuidString
        guard let publicKey = try? PublicKey(pemEncoded: publicKey),
              let clear = try? ClearMessage(string: str, using: .utf8),
              let encrypted = try? clear.encrypted(with: publicKey, padding: .PKCS1)
        else { return RSAData(key: "", verifyKey: "") }

        let base64String = encrypted.base64String

        return RSAData(key: str, verifyKey: base64String)
    }
}
