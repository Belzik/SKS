import UIKit
import SnapKit
import Kingfisher

protocol RZDTableViewCellDelegate: AnyObject {
    func favoriteButtonTapped()
}

class RZDTableViewCell: BaseTableViewCell {
    // MARK: - Views

    private var backgroungImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16

        return imageView
    }()

    private var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill

        return imageView
    }()

    private lazy var favoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(.init(named: "ic_heart_fill_gray"), for: .normal)
        button.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)

        return button
    }()

    private var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = Fonts.montserrat.bold.s24
        label.textColor = .white

        return label
    }()

    // MARK: - Properties

    weak var delegate: RZDTableViewCellDelegate?
    var model: Partner? {
        didSet {
            layout()
        }
    }

    // MARK: - Internal methods

    override func addSubviews() {
        contentView.addSubview(backgroungImageView)
        backgroungImageView.addSubview(logoImageView)
        contentView.addSubview(favoriteButton)
        backgroungImageView.addSubview(label)
    }

    override func setConstraints() {
        backgroungImageView.snp.makeConstraints {
            $0.left.right.top.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(24)
            $0.height.equalTo(180)
        }

        logoImageView.snp.makeConstraints {
            $0.left.top.equalToSuperview().inset(16)
            $0.height.equalTo(22)
            $0.width.equalTo(49)
        }

        favoriteButton.snp.makeConstraints {
            $0.top.right.equalToSuperview().inset(32)
            $0.height.width.equalTo(24)
        }

        label.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview().inset(16)
        }
    }

    // MARK: - Methods

    private func layout() {
        guard let model = model else { return }

        if let backgroundImageStr = model.bannerBackground,
           let url = URL(string: backgroundImageStr) {
            backgroungImageView.kf.setImage(with: url)
        }

        if let logoImageStr = model.bannerLogo,
           let url = URL(string: logoImageStr) {
            logoImageView.kf.setImage(with: url)
        }

        if let isFavorite = model.isFavorite,
           isFavorite {
            favoriteButton.setImage(.init(named: "ic_heart_fill"), for: .normal)
        } else {
            favoriteButton.setImage(.init(named: "ic_heart_fill_gray"), for: .normal)
        }

        label.text = model.bannerText
    }

    // MARK: - Actions

    @objc func favoriteButtonTapped() {
        delegate?.favoriteButtonTapped()

        if UserData.loadSaved() == nil { return }
        if let isFavorite = model?.isFavorite,
           isFavorite {
            favoriteButton.setImage(.init(named: "ic_heart_fill"), for: .normal)
        } else {
            favoriteButton.setImage(.init(named: "ic_heart_fill_gray"), for: .normal)
        }
    }
}
