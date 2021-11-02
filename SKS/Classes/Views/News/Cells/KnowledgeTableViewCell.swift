import UIKit
import SnapKit

protocol KnowledgeTableViewCellSource {
    var title: String { get }
}

class KnowledgeTableViewCell: BaseTableViewCell {
    // MARK: - Views

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.openSans.medium.s16
        label.textColor = ColorManager.lightBlack.value
        label.numberOfLines = 0

        return label
    }()

    private let iconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ic_right_arrow"))

        return imageView
    }()

    // MARK: - Properties

    var model: KnowledgeTableViewCellSource? {
        didSet {
            layout()
        }
    }

    // MARK: - Internal methods

    override func addSubviews() {
        addSubview(titleLabel)
        addSubview(iconView)
    }

    override func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview().inset(12)
        }

        iconView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().inset(16)
            $0.left.equalTo(titleLabel.snp.right).offset(8)
            $0.width.equalTo(8)
            $0.height.equalTo(14)
        }
    }

    // MARK: - Private methods

    private func layout() {
        titleLabel.text = model?.title
    }
}
