import UIKit
import XLPagerTabStrip

class RZDRequestViewController: BaseViewController {
    // MARK: - IBOutlets

    @IBOutlet weak var registrationLabel: UILabel!
    @IBOutlet weak var sendButton: DownloadButton!
    @IBOutlet weak var identifierTextField: UITextField!
    @IBOutlet weak var rzdRequestView: UIView!
    @IBOutlet weak var statusView: UIView!

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var messageRequestLabel: UILabel!
    @IBOutlet weak var sendRequestAgainLabel: UILabel!

    // MARK: - Properties

    weak var delegate: RZDPartnerScrollableDelegate?
    var rzdRequest: RzdRequest?
    var partner: Partner?

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        sendButton.layer.cornerRadius = 5
        setupRegistrationLabel()
        setupToolbar()
        layoutUI()
        setupLabels()
    }

    // MARK: - Methods

    func setupLabels() {
        let stringValue = sendRequestAgainLabel.text!

        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: stringValue)
        attributedString.setColorForText(textForAttribute: stringValue, withColor: ColorManager.green.value, isUnderline: true)

        sendRequestAgainLabel.attributedText = attributedString

        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedRequestAgain))
        sendRequestAgainLabel.isUserInteractionEnabled = true
        sendRequestAgainLabel.addGestureRecognizer(tap)
    }

    func setupToolbar() {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = false
        toolBar.tintColor = .black
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(cancelToolbar));
        doneButton.tintColor = ColorManager.green.value
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(cancelToolbar));

        toolBar.setItems([cancelButton,spaceButton,doneButton], animated: false)

        identifierTextField.inputAccessoryView = toolBar
    }

    @objc func cancelToolbar() {
        view.endEditing(true)
    }

    private func setupRegistrationLabel() {
        let stringValue = "01. Теперь нужно зарегистрироваться в системе «РЖД Бонус»"

        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: stringValue)
        attributedString.setColorForText(textForAttribute: "зарегистрироваться", withColor: ColorManager.green.value, isUnderline: true)

        registrationLabel.attributedText = attributedString

        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedRegisterLabel))
        registrationLabel.isUserInteractionEnabled = true
        registrationLabel.addGestureRecognizer(tap)
    }

    func sendRequest() {
        guard let id = identifierTextField.text else { return }

        NetworkManager.shared.sendRzdRequest(id: id) { [weak self] result in
            guard let self = self else { return }

            if let rzdRequest = result.value {
                self.rzdRequest = rzdRequest
                self.layoutUI()
            } else {
                self.showAlert(message: NetworkErrors.common)
            }
            self.sendButton.isDownload = false
        }
    }

    func getInfoUser() {
        if UserData.loadSaved() == nil {
            showAlert(message: "Войдите или зарегистрируйтесь, чтобы отправить заявку")
            return
        }

        guard let id = identifierTextField.text else { return }
        if id.count != 13 {
            showAlert(message: "Неверный идентификатор, необходимо ввести 13 цифр.")
            return
        }

        sendButton.isDownload = true
        NetworkManager.shared.getInfoUser { [weak self] response in
            if let user = response.value {
                if let status = user.status,
                   status == "active" {
                    self?.sendRequest()
                } else {
                    self?.showAlert(message: "Для подачи заявки подтвердите аккаунт в профкоме")
                }
            } else {
                self?.sendButton.isDownload = false
                self?.showAlert(message: NetworkErrors.common)
            }
        }
    }

    func layoutUI() {
        if let rzdRequest = rzdRequest {
            switch rzdRequest.statusRequest {
            case .atWork:
                statusLabel.text = "В работе"
                statusLabel.textColor = ColorManager.lightBlack.value
                messageRequestLabel.text = "Твоя заявка принята и уже отправлена в РЖД. Скоро путешествия станут дешевле."
                sendRequestAgainLabel.isHidden = true
            case .approved:
                statusLabel.text = "Успешно"
                statusLabel.textColor = ColorManager.green.value
                messageRequestLabel.text = "Твоя заявка успешно подтверждена. Теперь ты можешь пользоваться скидками РЖД Бонус"
                sendRequestAgainLabel.isHidden = true
            case .rejected:
                statusLabel.text = "Отклонена"
                statusLabel.textColor = ColorManager._EA2525.value
                messageRequestLabel.text = rzdRequest.message
                sendRequestAgainLabel.isHidden = false
            }

            statusView.isHidden = false
            rzdRequestView.isHidden = true
        } else {
            statusView.isHidden = true
            rzdRequestView.isHidden = false
        }
    }

    // MARK: - Actions

    @IBAction func sendButtonTapped(_ sender: SKSButton) {
        getInfoUser()
    }

    @objc func tappedRegisterLabel() {
        if let link = partner?.linkToSite,
            let url = URL(string: link) {
            UIApplication.shared.open(url)
        }
    }

    @objc func tappedRequestAgain() {
        statusView.isHidden = true
        rzdRequestView.isHidden = false
    }
}

// MARK: - IndicatorInfoProvider
extension RZDRequestViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Заявка")
    }
}

// MARK: - UIScrollViewDelegate
extension RZDRequestViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView: scrollView)
    }
}
