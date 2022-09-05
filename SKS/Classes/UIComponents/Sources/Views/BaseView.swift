import UIKit.UIView

open class BaseView: UIView {
    // MARK: - Initializers

    required public init() {
        super.init(frame: .zero)
        setup()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Open methods

    open func setup() {}
}
