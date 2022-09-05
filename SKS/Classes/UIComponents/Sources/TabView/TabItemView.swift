import UIKit
import SnapKit

class TabItemView: SnapKitView {
    // MARK: - Views

    private var stackButton: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6

        return stack
    }()

    let button: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = Fonts.openSans.medium.s16
        button.setTitleColor(ColorManager.lightBlack.value, for: .normal)
        button.setTitleColor(ColorManager.green.value, for: .selected)
        button.tintColor = .clear
        button.imageView?.contentMode = .scaleAspectFit

        button.contentMode = .center
        button.isUserInteractionEnabled = false

        return button
    }()

    let circleView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorManager.green.value
        view.layer.cornerRadius = 11
        view.isHidden = true

        return view
    }()

    let countLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.montserrat.bold.s11
        label.textColor = .white

        return label
    }()

    // MARK: - Properties

    var count: Int = 0

    // MARK: - Initializers

    convenience init(index: Int, title: String, count: Int) {
        self.init()
        self.count = count
        button.setTitle(title, for: .normal)
        button.tag = index
        countLabel.text = "\(count)"
        backgroundColor = .clear

        if count == 0 {
            circleView.isHidden = true
        }
    }

    // MARK: - Internal methods

    override func addSubviews() {
        addSubview(stackButton)
        circleView.addSubview(countLabel)
        stackButton.addArrangedSubview(button)
        stackButton.addArrangedSubview(circleView)
    }

    override func setConstraints() {
        countLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(8)
            $0.top.equalToSuperview().inset(4)
            $0.bottom.equalToSuperview().inset(3)
        }

        circleView.snp.makeConstraints {
            $0.height.equalTo(22)
        }

        stackButton.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
        }
    }
}
