import UIKit
import SnapKit

class BackView: SnapKitView {
    // MARK: - Views

    private let backImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ic_left_arrow_back"))

        return imageView
    }()

    private let backLabel: UILabel = {
        let label = UILabel()
        label.text = "Назад"
        label.font = Fonts.montserrat.medium.s16
        label.textColor = ColorManager.lightBlack.value

        return label
    }()

    // MARK: - Internal methods

    override func addSubviews() {
        addSubview(backImageView)
        addSubview(backLabel)
    }

    override func setConstraints() {
        backImageView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalTo(8)
            $0.height.equalTo(14)
        }

        backLabel.snp.makeConstraints {
            $0.left.equalTo(backImageView.snp.right).offset(12)
            $0.top.bottom.right.equalToSuperview()
        }
    }
}
