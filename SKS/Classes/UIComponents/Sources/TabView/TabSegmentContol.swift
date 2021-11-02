import UIKit
import SnapKit
import SwiftUI

protocol TabSegmentedControlDelegate: AnyObject {
    func changeView(to index: Int)
}

class TabSegmentedControl: SnapKitView {
    // MARK: - Public properties

    weak var delegate: TabSegmentedControlDelegate?
    var buttons: [UIButton] {
        return buttonsStack.arrangedSubviews.compactMap { $0 as? UIButton }
    }

    // MARK: - Private properties
    private let selectorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constant.selectorCornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.backgroundColor = Constant.selectorColor
        view.clipsToBounds = true

        return view
    }()

    private let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually

        return stack
    }()

    private(set) var selectedIndex: Int = 0

    // MARK: - Initializers

    private func createButton(title: String) -> UIButton {
        let button = UIButton(type: .system)

        button.titleLabel?.font = Fonts.openSans.medium.s16
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
        button.setTitleColor(Constant.titleColor, for: .normal)
        button.setTitleColor(Constant.selectedTitleColor, for: .selected)
        button.tintColor = .clear
        button.imageView?.contentMode = .scaleAspectFit

        button.contentMode = .center

        return button
    }

    // MARK: - Public methods

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        // initialization
        if selectorView.frame == .zero {
            let selectorWidth = Int(self.frame.width) / buttonsStack.arrangedSubviews.count

            selectorView.frame = CGRect(
                x: 0,
                y: Int(self.frame.height) - Constant.selectorHeight,
                width: selectorWidth,
                height: Constant.selectorHeight
            )
        }
    }

    func configure(with items: [String]) {
        cleanupStack()

        if !items.isEmpty {
            for item in items {
                buttonsStack.addArrangedSubview(createButton(title: item))
            }
            selectButton(0)
        } else {
            return
        }
    }

    func selectButton(_ buttonIndex: Int) {
        selectedIndex = buttonIndex
        for (index, button) in buttonsStack.arrangedSubviews.compactMap({ $0 as? UIButton }).enumerated() {
            button.isSelected = index == selectedIndex
            button.backgroundColor = .clear
        }

        let selectorWidth = Int(self.frame.width) / buttonsStack.arrangedSubviews.count
        let selectorPosition = CGFloat(selectorWidth * (selectedIndex + 1) - selectorWidth)

        UIView().animateCurveLinear {
            self.selectorView.frame.origin.x = selectorPosition
        }
    }

    @objc func buttonAction(sender: UIButton) {
        guard let buttonIndex = buttonsStack.arrangedSubviews.firstIndex(of: sender) else { return }

        selectButton(buttonIndex)
        delegate?.changeView(to: buttonIndex)
    }

    // MARK: - Private methods

    private func cleanupStack() {
        for subview in buttonsStack.arrangedSubviews {
            buttonsStack.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }

    override func addSubviews() {
        addSubview(selectorView)
        addSubview(buttonsStack)
    }

    override func setConstraints() {
        buttonsStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - Constants

extension TabSegmentedControl {
    enum Constant {
        static let selectorHeight = 2
        static let selectorCornerRadius: CGFloat = 1
        static let titleColor = ColorManager.lightBlack.value
        static let selectedTitleColor = ColorManager.green.value
        static let selectorColor = ColorManager.green.value
    }
}
