import UIKit

open class BaseTableViewCell: UITableViewCell, Reusable {
    // MARK: - Initializers

    required public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
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
