public protocol Reusable: AnyObject {
    static var reuseIdentifier: String { get }
}

public extension Reusable {
    // MARK: - Properties

    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
