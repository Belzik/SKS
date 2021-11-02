import UIKit.UIView

open class BaseView: UIView {
    // MARK: - Initializers

    required public init() {
        super.init(frame: .zero)
        setup()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Open methods

    open func setup() {}
}
