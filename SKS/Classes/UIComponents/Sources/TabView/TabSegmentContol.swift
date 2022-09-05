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

    private func createButton(index: Int, title: String, count: Int) -> UIView {
        let baseView = TabItemView(index: index, title: title, count: count)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        baseView.addGestureRecognizer(tap)
        baseView.isUserInteractionEnabled = true
        baseView.snp.makeConstraints {
            $0.height.equalTo(34)
        }

        return baseView
    }

    // MARK: - Public methods

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        // initialization
        if buttonsStack.arrangedSubviews.count != 0 {
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
    }

    func configure(with items: [TabElement]) {
        cleanupStack()

        if !items.isEmpty {
            for (index, item) in items.enumerated() {
                buttonsStack.addArrangedSubview(createButton(index: index, title: item.title, count: item.count))
            }
            selectButton(0)
        } else {
            return
        }
    }

    func changeCountOfItems(count: Int) {
        if let view = buttonsStack.arrangedSubviews.first as? TabItemView {
            view.countLabel.text = "\(count)"
            view.circleView.isHidden = count == 0
        }
    }

    func selectButton(_ buttonIndex: Int) {
        selectedIndex = buttonIndex

        for view in buttonsStack.arrangedSubviews {
            if let view = view as? TabItemView {
                let button = view.button

                button.isSelected = button.tag == selectedIndex
                button.backgroundColor = .clear

                if button.tag == selectedIndex {
                    UIView().animateCurveLinear {
                        self.selectorView.frame.origin.x = view.frame.origin.x
                    }
                }
            }
        }
    }

    @objc func buttonAction(_ sender: UIView) {
        guard let buttonIndex = buttonsStack.arrangedSubviews.firstIndex(of: sender) else { return }

        selectButton(buttonIndex)
        delegate?.changeView(to: buttonIndex)
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        guard let buttonIndex = buttonsStack.arrangedSubviews.firstIndex(of: view) else { return }

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
