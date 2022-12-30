//
//  PromoDataViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 04.12.2022.
//  Copyright © 2022 Katrych. All rights reserved.
//

import UIKit

class PromoDataViewController: BaseViewController {
    // MARK: - Views

    @IBOutlet weak var cityTextField: ErrorTextField!
    @IBOutlet weak var BYZtextField: ErrorTextField!
    @IBOutlet weak var endButton: DownloadButton!

    // MARK: - Properties

    var uniqueSess = ""
    var refreshToken = ""
    var accessToken = ""
    var keyFile = ""
    var surname = ""
    var name = ""
    var patronymic = ""
    var birthday = ""

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        cityTextField.textField.delegate = self
        BYZtextField.textField.delegate = self
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    // MARK: - Methods

    func validate() -> Bool {
        var isValid = true

        if cityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            cityTextField.errorMessage = "Поле не заполнено"
            isValid = false
        }

        if BYZtextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            BYZtextField.errorMessage = "Поле не заполнено"
            isValid = false
        }

        return isValid
    }

    func regis() {
        let request = PromoRequest(
            uniqueSess: uniqueSess,
            name: name,
            patronymic: patronymic,
            surname: surname,
            birthdate: birthday,
            keyPhoto: keyFile,
            nameCity: cityTextField.text!,
            nameUniversity: BYZtextField.text!
        )
        endButton.isDownload = true
        NetworkManager.shared.sendPromoData(
            model: request,
            accessToken: accessToken
        ) { [weak self] response in
            if let user = response.value,
                    user.uuidUser != nil {
                user.accessToken = self?.accessToken
                user.refreshToken = self?.refreshToken
                user.uniqueSess = self?.uniqueSess
                user.save()

                if let vc = UIStoryboard(name: "Home", bundle: nil).instantiateInitialViewController() {
                    vc.modalPresentationStyle = .fullScreen
                    self?.present(vc, animated: true, completion: nil)
                }
            } else {
                self?.showAlert(message: NetworkErrors.common)
            }
            self?.endButton.isDownload = false
        }
    }
    
    // MARK: - Actions

    @IBAction func endButtonTapped(_ sender: DownloadButton) {
        if validate() {
            regis()
        }
    }

}

extension PromoDataViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
