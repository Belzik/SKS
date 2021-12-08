import SnapKit
import UIKit

class ComplaintAboutNewViewController: ViewController<ComplaintAboutNewsView> {
    // MARK: - Properties

    var uuidNews: String?

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: - Private methods

    private func setup() {
        mainView.sendHandler = { [weak self] in
            self?.sendComplaint()
        }

        mainView.cancelHandler = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }

    private func sendComplaint() {
        guard let uuidNews = uuidNews else { return }

        if !mainView.repeatedSwitch.isOn &&
            !mainView.noActualSwitch.isOn &&
            (mainView.textView.text == "Другая причина" ||
            mainView.textView.text == "") {
                showAlert(message: "Выберите хотя-бы одну причину.")
            return
        }

        var complaint = ""

        if mainView.repeatedSwitch.isOn {
            complaint = "Повторяющаяся"
        }

        if mainView.noActualSwitch.isOn {
            if complaint == "" {
                complaint = "Неактуальная"
            } else {
                complaint += ", неактуальная"
            }
        }

        if (mainView.textView.text != "Другая причина" &&
            mainView.textView.text != "") {
            let text = mainView.textView.text!
            if complaint == "" {
                complaint = text
            } else {
                complaint += ". \(text)"
            }
        }

        mainView.sendButton.isDownload = true
        NetworkManager.shared.sendComplaintAboutNews(uuidNews: uuidNews, complaint: complaint) { [weak self] result in
            guard let self = self else { return }

            self.mainView.sendButton.isDownload = false
            if let responseCode = result.responseCode,
               responseCode == 200 {
                self.dismiss(animated: true, completion: nil)
            } else if let responseCode = result.responseCode,
                        responseCode == 403  {
                self.showAlert(message: "Аккаунт не подтвержден. Для того, чтобы отправлять жалобы, подтвердите аккаунт.")
            } else {
                self.showAlert(message: NetworkErrors.common)
            }
        }
    }
}
