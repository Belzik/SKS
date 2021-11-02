import UIKit.UITableView

public extension UITableView {
    // MARK: - Reusable for UITableViewCell

    final func register<T: UITableViewCell>(_ cellClass: T.Type) where T: Reusable {
        self.register(cellClass.self, forCellReuseIdentifier: cellClass.reuseIdentifier)
    }

    final func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath, cellClass: T.Type = T.self) -> T where T: Reusable {
        return self.dequeueReusableCell(withIdentifier: cellClass.reuseIdentifier, for: indexPath) as! T
    }
}
