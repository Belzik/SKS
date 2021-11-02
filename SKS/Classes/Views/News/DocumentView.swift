import UIKit
import SnapKit

class DocumentView: SnapKitView {
    // MARK: - Views

    private let documentImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ic_paperclip"))

        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.montserrat.bold.s16
        label.textColor = ColorManager.green.value
        label.numberOfLines = 0

        return label
    }()

    private let mbLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.montserrat.regular.s16
        label.textColor = ColorManager._767B8B.value

        return label
    }()

    // MARK: - Initializers

    convenience init(name: String, mb: String) {
        self.init()
        nameLabel.text = name
        mbLabel.text = "(\(mb)МБ)"
    }

    // MARK: - Internal methods

    override func addSubviews() {
        addSubview(documentImageView)
        addSubview(nameLabel)
        addSubview(mbLabel)
    }

    override func setConstraints() {
        documentImageView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.centerY.equalTo(nameLabel.snp.centerY)
            $0.width.height.equalTo(24)
        }

        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(4)
            $0.left.equalTo(documentImageView.snp.right).offset(8)
            $0.right.equalToSuperview()
        }

        mbLabel.snp.makeConstraints {
            $0.left.equalTo(documentImageView.snp.right).offset(8)
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
            $0.bottom.right.equalToSuperview()
        }
    }
}
