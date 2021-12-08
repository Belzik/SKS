import UIKit
import SnapKit

class ComplaintAboutNewsView: SnapKitView {
    // MARK: - Views

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.montserrat.bold.s20
        label.textColor = ColorManager.lightBlack.value
        label.text = "Подать жалобу"

        return label
    }()

    private lazy var backImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "close"))
        let tap = UITapGestureRecognizer(target: self, action: #selector(backImageViewTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)

        return imageView
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.openSans.regular.s16
        label.textColor = ColorManager.lightBlack.value
        label.text = "Выберите причину жалобы или опишите ее в поле ниже"
        label.numberOfLines = 0

        return label
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12

        return stackView
    }()

    private let noActualView = UIView()
    private let noActualLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.montserrat.medium.s16
        label.textColor = ColorManager.lightBlack.value
        label.text = "Неактаульная"

        return label
    }()
    let noActualSwitch = UISwitch()

    private let repeatedView = UIView()
    private let repeatedLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.montserrat.medium.s16
        label.textColor = ColorManager.lightBlack.value
        label.text = "Повторяющаяся"

        return label
    }()
    let repeatedSwitch = UISwitch()

    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.contentInset = UIEdgeInsets(top: -4, left: -6, bottom: 0, right: -6)
        textView.text = "Другая причина"
        textView.textColor = ColorManager.lightGray.value
        textView.font = Fonts.openSans.regular.s16
        textView.delegate = self

        return textView
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorManager.lightGray.value

        return view
    }()

    let sendButton: DownloadButton = {
        let button = DownloadButton()
        button.titleLabel?.font = Fonts.montserrat.bold.s16
        button.setTitle("Отправить", for: .normal)
        button.layer.cornerRadius = 8
        button.backgroundColor = ColorManager.green.value
        button.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)

        return button
    }()

    // MARK: - Properties

    var sendHandler: (() -> Void)?
    var cancelHandler: (() -> Void)?

    // MARK: - Internal methods

    override func addSubviews() {
        addSubview(titleLabel)
        addSubview(backImageView)
        addSubview(descriptionLabel)
        addSubview(stackView)
        stackView.addArrangedSubview(noActualView)
        noActualView.addSubview(noActualLabel)
        noActualView.addSubview(noActualSwitch)
        stackView.addArrangedSubview(repeatedView)
        repeatedView.addSubview(repeatedLabel)
        repeatedView.addSubview(repeatedSwitch)
        addSubview(textView)
        addSubview(separatorView)
        addSubview(sendButton)
    }

    override func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(16)
        }

        backImageView.snp.makeConstraints {
            $0.top.right.equalToSuperview().inset(16)
            $0.width.equalTo(24)
            $0.height.equalTo(24)
        }

        descriptionLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(16)
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
        }

        stackView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(16)
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(24)
        }

        noActualLabel.snp.makeConstraints {
            $0.left.top.bottom.equalToSuperview()
        }

        noActualSwitch.snp.makeConstraints {
            $0.right.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(2)
        }

        repeatedLabel.snp.makeConstraints {
            $0.left.top.bottom.equalToSuperview()
        }

        repeatedSwitch.snp.makeConstraints {
            $0.right.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(2)
        }

        textView.snp.makeConstraints {
            $0.right.left.equalToSuperview().inset(16)
            $0.top.equalTo(stackView.snp.bottom).offset(32)
        }

        separatorView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(16)
            $0.top.equalTo(textView.snp.bottom).offset(4)
            $0.height.equalTo(1)
        }

        sendButton.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(textView.snp.bottom).offset(16)
            $0.height.equalTo(48)
            $0.left.right.bottom.equalTo(safeAreaLayoutGuide).inset(16)
        }
    }

    // MARK: - Actions

    @objc func backImageViewTapped() {
        cancelHandler?()
    }

    @objc func sendButtonTapped() {
        sendHandler?()
    }
}

extension ComplaintAboutNewsView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == ColorManager.lightGray.value {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Другая причина"
            textView.textColor = ColorManager.lightGray.value
        }
    }
}
