import UIKit
import SnapKit

class TitleWithIconButton: SnapKitView {
    // MARK: - Views

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10

        return stackView
    }()

    let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = Fonts.montserrat.bold.s16
        label.textColor = .white

        return label
    }()

    // MARK: - Internal methods

    override func addSubviews() {
        addSubview(stackView)
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(titleLabel)
    }

    override func setConstraints() {
        stackView.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
        }

        iconView.snp.makeConstraints {
            $0.height.width.equalTo(20)
        }
    }
}
