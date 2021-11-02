open class SnapKitView: BaseView {
    // MARK: - Open methods

    override open func setup() {
        backgroundColor = .white
        addSubviews()
        setConstraints()
    }
    // Must be override
    open func addSubviews() {}
    open func setConstraints() {}
}
