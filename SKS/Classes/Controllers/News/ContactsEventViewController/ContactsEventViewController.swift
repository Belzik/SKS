import SnapKit
import UIKit

class ContactsEventViewController: ViewController<ContactsEventView> {
    // MARK: - Properties

    var user: UserData?

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: - Private methods

    private func setup() {
        mainView.vkTextField.text = user?.studentInfo?.linkvk
        mainView.telegramTexTfield.text = user?.studentInfo?.linktg

        if mainView.vkTextField.text == "" {
            mainView.vkTextField.text = mainView.vkPrefix
        }

        if mainView.telegramTexTfield.text == "" {
            mainView.telegramTexTfield.text = mainView.telegramPrefix
        }

        mainView.sendHandler = { [weak self] in
            self?.sendComplaint()
        }

        mainView.cancelHandler = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }

    private func sendComplaint() {
        let vk = mainView.vkTextField.text ?? ""
        let telegram = mainView.telegramTexTfield.text ?? ""

        if vk.trimmingCharacters(in: .whitespacesAndNewlines) == "" &&
            telegram.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            self.showAlert(message: "Заполните хотя-бы одно поле.")
            return
        }

        if !(vk.contains("vk.com")),
           vk.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            self.showAlert(message: "Некорректная ссылка на Вконтакте")
            return
        }

        if !(telegram.contains("t.me")),
           telegram.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            self.showAlert(message: "Некорректная ссылка на Телеграм")
            return
        }

        mainView.sendButton.isDownload = true
        NetworkManager.shared.sendSocnet(vk: vk, telegram: telegram) { [weak self] result in
            guard let self = self else { return }

            self.user?.studentInfo?.linktg = telegram
            self.user?.studentInfo?.linkvk = vk

            self.mainView.sendButton.isDownload = false
            if let responseCode = result.responseCode,
               responseCode == 200 {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.showAlert(message: NetworkErrors.common)
            }
        }
    }
}
