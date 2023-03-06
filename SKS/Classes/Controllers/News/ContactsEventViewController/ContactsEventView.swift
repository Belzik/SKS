import UIKit
import SnapKit

class ContactsEventView: SnapKitView {
    // MARK: - Views

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.montserrat.bold.s20
        label.textColor = ColorManager.lightBlack.value
        label.text = "Оставить контакты\nдля связи"
        label.numberOfLines = 0
        label.textAlignment = .center

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
        label.text = "Будет здорово, если оставишь свой ВК или Telegram. Это поможет связаться с тобой в случае необходимости.\nОбещаем не спамить 😉"
        label.numberOfLines = 0

        return label
    }()

    private var vkImageView = UIImageView(image: UIImage(named: "ic_vc_contact"))
    lazy var vkTextField: ErrorTextField = {
        let textField = ErrorTextField()
        textField.placeholder = "Ссылка на страницу ВК"
        textField.textField.title = ""
        textField.textField.delegate = self

        return textField
    }()

    private var telegramImageView = UIImageView(image: UIImage(named: "ic_telegram_contact"))
    lazy var telegramTexTfield: ErrorTextField = {
        let textField = ErrorTextField()
        textField.placeholder = "Ссылка на Telegram"
        textField.textField.title = ""
        textField.textField.delegate = self

        return textField
    }()

    lazy var sendButton: DownloadButton = {
        let button = DownloadButton()
        button.titleLabel?.font = Fonts.montserrat.bold.s16
        button.setTitle("Отправить", for: .normal)
        button.layer.cornerRadius = 8
        button.backgroundColor = ColorManager.green.value
        button.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)

        return button
    }()

    // MARK: - Properties

    let vkPrefix = "https://vk.com/"
    let telegramPrefix = "https://t.me/"
    var sendHandler: (() -> Void)?
    var cancelHandler: (() -> Void)?

    // MARK: - Internal methods

    override func addSubviews() {
        addSubview(titleLabel)
        addSubview(backImageView)
        addSubview(descriptionLabel)
        addSubview(vkImageView)
        addSubview(vkTextField)
        addSubview(telegramImageView)
        addSubview(telegramTexTfield)
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

        vkImageView.snp.makeConstraints {
            $0.left.equalToSuperview().inset(16)
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(32)
            $0.width.height.equalTo(32)
        }

        vkTextField.snp.makeConstraints {
            $0.left.equalTo(telegramImageView.snp.right).offset(16)
            $0.right.equalToSuperview().inset(16)
            $0.bottom.equalTo(telegramImageView.snp.top).offset(-8)
            $0.height.equalTo(65)
        }

        telegramImageView.snp.makeConstraints {
            $0.left.equalToSuperview().inset(16)
            $0.top.equalTo(vkImageView.snp.bottom).offset(24)
            $0.width.height.equalTo(32)
        }

        telegramTexTfield.snp.makeConstraints {
            $0.left.equalTo(telegramImageView.snp.right).offset(16)
            $0.right.equalToSuperview().inset(16)
            $0.bottom.equalTo(telegramImageView.snp.bottom).offset(16)
        }

        sendButton.snp.makeConstraints {
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

extension ContactsEventView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var prefix: NSMutableAttributedString
        if textField == vkTextField.textField {
            prefix = NSMutableAttributedString(string: vkPrefix)
        } else {
            prefix = NSMutableAttributedString(string: telegramPrefix)
        }

        let protectedRange = NSRange(location: 0, length: prefix.length)
        let intersection = protectedRange.intersection(range)

        // prevent deleting prefix
        if intersection != nil {
            return false
        }

        return true
    }
}

