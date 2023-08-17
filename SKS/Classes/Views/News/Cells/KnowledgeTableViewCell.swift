import UIKit
import SnapKit
import Kingfisher

protocol KnowledgeTableViewCellSource {
    var title: String { get }
    var pict: String? { get }
}

class KnowledgeTableViewCell: BaseTableViewCell {
    // MARK: - Views

    private let iconView = UIImageView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.openSans.medium.s16
        label.textColor = ColorManager.lightBlack.value
        label.numberOfLines = 0

        return label
    }()

    private let arrowImageView: UIImageView = {
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
        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(arrowImageView)
    }

    override func setConstraints() {
        iconView.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.left.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(12)
            $0.left.equalTo(iconView.snp.right).offset(12)
        }

        arrowImageView.snp.makeConstraints {
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
        if let link = model?.pict,
           let url = URL(string: NetworkManager.shared.apiEnvironment.baseURI + link) {
            iconView.isHidden = false
            iconView.kf.setImage(with: url)
        } else {
            iconView.isHidden = true
            iconView.snp.removeConstraints()

            titleLabel.snp.makeConstraints {
                $0.top.bottom.equalToSuperview().inset(12)
                $0.left.equalToSuperview().offset(12)
            }
        }
    }
}
