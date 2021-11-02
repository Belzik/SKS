import UIKit.UICollectionView

public extension UICollectionView {
    // MARK: - Reusable for UICollectionViewCell

    final func register<T: UICollectionViewCell>(cellClass: T.Type) where T: Reusable {
        self.register(cellClass.self, forCellWithReuseIdentifier: cellClass.reuseIdentifier)
    }

    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath, cellClass: T.Type = T.self) -> T where T: Reusable {
        // swiftlint:disable:next force_cast
        return dequeueReusableCell(withReuseIdentifier: cellClass.reuseIdentifier, for: indexPath) as! T
    }
}
