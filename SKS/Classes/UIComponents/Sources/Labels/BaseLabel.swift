import UIKit.UILabel

open class BaseLabel: UILabel {
    // MARK: - Initializers

    required public init() {
        super.init(frame: .zero)
        setup()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public convenience init(text: String?) {
        self.init()
        self.text = text
    }

    // MARK: - Open methods

    open func setup() {
        numberOfLines = 0
    }
}
