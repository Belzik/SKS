import UIKit

open class BaseCollectionViewCell: UICollectionViewCell, Reusable {
    // MARK: - Initializers

    required public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Open methods

    open func setup() {
        addSubviews()
        setConstraints()
    }
    // Must be override
    open func addSubviews() {}
    open func setConstraints() {}
}
