import UIKit

class PromocodeViewController: BaseViewController {
    // MARK: - Views

    @IBOutlet weak var textField: ErrorTextField!
    @IBOutlet weak var promoTitle: UILabel!
    @IBOutlet weak var promoDescription: UILabel!
    @IBOutlet weak var button: DownloadButton!

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        promoTitle.isHidden = true
        promoDescription.isHidden = true
        textField.errorLabel.textAlignment = .left
    }

    // MARK: Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueLogin" {
            let dvc = segue.destination as! LoginViewController
            dvc.isPromo = true
            dvc.promocode = textField.text!
        }
    }

    // MARK: - Methods



    // MARK: - Actions

    @IBAction func buttonTapped(_ sender: DownloadButton) {
        if (sender.titleLabel?.text) == "Далее" {
            performSegue(withIdentifier: "segueLogin", sender: nil)
        } else {
            sender.isDownload = true
            NetworkManager.shared.checkPromo(promo: textField.text!) { [weak self] result in
                guard let self = self else { return }
                sender.isDownload = false
                if let responseCode = result.responseCode,
                    responseCode == 409 {
                    self.showAlert(message: "Промокод не найден")
                } else if let promoData = result.value {
                    if let status = promoData.status,
                        status == "expired" {
                        self.showAlert(message: "Промокод истек")
                    } else {
                        self.promoTitle.isHidden = false
                        if let date =  promoData.expirationDate {
                            self.promoDescription.text = "Срок действия до " + DateManager.shared.toDateString(date: date)
                        }
                        self.promoDescription.isHidden = false
                        sender.setTitle("Далее", for: .normal)
                    }
                } else {
                    self.showAlert(message: NetworkErrors.common)
                }
            }
        }
    }
}
