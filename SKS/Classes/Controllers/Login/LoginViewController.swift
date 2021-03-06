//
//  ViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 29/06/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit
import SwiftyVK

class LoginViewController: BaseViewController {
    @IBOutlet weak var phoneTextField: SKSTextField!
    @IBOutlet weak var nextButton: SKSButton!
    @IBOutlet weak var agreementsLabel: UILabel!
    @IBOutlet weak var bottomConstraintAgreementLabel: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var acitivityIndicator: UIActivityIndicatorView!
    
    private var keyboardHeight: CGFloat = 0
    private var smsResponse: SmsResponse?
    var authVKReponse: AuthVKResponse?
    
    @IBAction override func backButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextbuttonTapped(_ sender: SKSButton) {
        getSmsWithCode()
    }
    
    @IBAction func vkButtonTapped(_ sender: UIButton) {
        VK.sessions.default.logOut()
        
        VK.sessions.default.logIn(
            onSuccess: { _ in
              
            },
            onError: { error in
                
            }
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        VK.setUp(appId: "7275432", delegate: self)
        
        if UIDevice.modelName == "iPhone 5s" ||
            UIDevice.modelName ==  "iPhone SE" ||
            UIDevice.modelName ==  "Simulator iPhone SE" {
            let font = UIFont(name: "Montserrat-Bold", size: 20)!
            self.titleLabel.font = font
            titleLabelBottomConstraint.constant = 16
        }
        
        phoneTextField.rightView = UIImageView(image: UIImage(named: "ic_checked_green"))
        phoneTextField.rightView?.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        phoneTextField.rightViewMode = .always
        phoneTextField.rightView?.alpha = 0
        phoneTextField.rightView?.isHidden = true
        let stringValue = "Нажимая кнопку \"Далее\", я соглашаюсь с Политикой конфиденциальности"
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: stringValue)
        attributedString.setColorForText(textForAttribute: "Политикой конфиденциальности", withColor: ColorManager.green.value)
        
        agreementsLabel.attributedText = attributedString
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        setupAgreementsLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        phoneTextField.becomeFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueCode" {
            let dvc = segue.destination as! CodeViewController
            dvc.keyboardHeight = keyboardHeight
            dvc.phone = phoneTextField.text!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                
            dvc.smsResponse = self.smsResponse
        }
        
        if segue.identifier == "seguePassword" {
            let dvc = segue.destination as! PasswordViewController
            dvc.smsResponse = self.smsResponse
            dvc.phone = phoneTextField.text!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        }
        
        if segue.identifier == "seguePersonalData" {
            let dvc = segue.destination as! PersonalDataViewController
            
            if let uniqueSess = authVKReponse?.uniqueSess,
                let refreshToken = authVKReponse?.tokens?.refreshToken,
                let accessToken = authVKReponse?.tokens?.accessToken {
                dvc.uniqueSess = uniqueSess
                dvc.refreshToken = refreshToken
                dvc.accessToken = accessToken
                dvc.possibleData = authVKReponse?.possibleData
                dvc.isVK = true
            }
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            bottomConstraintAgreementLabel.constant = keyboardHeight + 16
            self.keyboardHeight = keyboardHeight
            
        }
    }
    
    func setupAgreementsLabel() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(agreementsLabelTapped))
        agreementsLabel.isUserInteractionEnabled = true
        agreementsLabel.addGestureRecognizer(tap)
    }
    
    @objc func agreementsLabelTapped() {
        performSegue(withIdentifier: "segueAgreements", sender: nil)
    }
    
    private func getSmsWithCode() {
        NetworkManager.shared.getCodeWithSms(phone: phoneTextField.text!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) { [weak self] response in
            
            if let smsResponse = response.value {
                self?.smsResponse = smsResponse
                
                if let loginKey = smsResponse.loginKey,
                    loginKey == "" {
                    self?.performSegue(withIdentifier: "segueCode", sender: nil)
                } else {
                    self?.performSegue(withIdentifier: "seguePassword", sender: nil)
                }
            } else {
                self?.showAlert(message: NetworkErrors.common)
            }
        }
    }
    
    private func views(hide: Bool) {
        UIView.transition(with: view, duration: 0.2, options: .transitionCrossDissolve, animations: { [weak self] in
            self?.view.layoutIfNeeded()
            self?.nextButton.isHidden = hide
            self?.agreementsLabel.isHidden = hide
            self?.phoneTextField.rightView?.isHidden = hide
        })
    }
    
    private func setupError(forTextField textField: SKSTextField, isDeleted: Bool) {
        if textField == phoneTextField {
                if !phoneTextField.text!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined().isPhone() {
                    phoneTextField.selectedLineColor = ColorManager.green.value
                    if isDeleted {
                        views(hide: true)
                    }
                } else {
                    phoneTextField.selectedLineColor = UIColor.gray
                    views(hide: false)
                }
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setupError(forTextField: textField as! SKSTextField, isDeleted: false)
        
        if textField == phoneTextField {
            if textField.text == "" {
                textField.text = "+7 "
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        let isDeleted = newString.count < textField.text!.count
        
        let currentText: NSString = textField.text as NSString? ?? ""
        
        let newText = currentText.replacingCharacters(in: range, with: string)
        let formattedString = newText.with(mask: "+* (***) ***-**-**", replacementChar: "*", isDecimalDigits: true)
        
        guard let finalText = formattedString as NSString? else { return false }
        
        if finalText == currentText && range.location < currentText.length && range.location > 0 {

            
            return self.textField(textField, shouldChangeCharactersIn: NSRange(location: range.location - 1, length: range.length + 1) , replacementString: string)
        }
        
        
        if finalText != currentText {
            textField.text = finalText as String

            // the user is trying to delete something so we need to
            // move the cursor accordingly
            if range.location < currentText.length {
                var cursorLocation = 0
                
                if range.location > finalText.length {
                    cursorLocation = finalText.length
                } else if currentText.length > finalText.length {
                    cursorLocation = range.location
                } else {
                    cursorLocation = range.location + 1
                }
                
                guard let startPosition = textField.position(from: textField.beginningOfDocument, offset: cursorLocation) else { return false }
                guard let endPosition = textField.position(from: startPosition, offset: 0) else { return false }
                textField.selectedTextRange = textField.textRange(from: startPosition, to: endPosition)
            }
            
            setupError(forTextField: textField as! SKSTextField, isDeleted: isDeleted)
            return false
        }
        
        setupError(forTextField: textField as! SKSTextField, isDeleted: isDeleted)
        return false
    }
}

extension LoginViewController: SwiftyVKDelegate {
    func vkNeedsScopes(for sessionId: String) -> Scopes {
        let scopes: Scopes = [.offline,.wall]
      // Called when SwiftyVK attempts to get access to user account
      // Should return a set of permission scopes
        return scopes
    }

    func vkNeedToPresent(viewController: VKViewController) {
      // Called when SwiftyVK wants to present UI (e.g. webView or captcha)
//        if var topController = UIApplication.shared.keyWindow?.rootViewController {
//            while let presentedViewController = topController.presentedViewController {
//                topController = presentedViewController
//            }
//
//            topController.present(viewController, animated: true)
//        }
//
        present(viewController, animated: true)
    }

    func vkTokenCreated(for sessionId: String, info: [String : String]) {
        if let userId = info["user_id"],
            let accessToken = info["access_token"] {
            authVK(vkToken: accessToken, userId: userId)
        }
    }

    func vkTokenUpdated(for sessionId: String, info: [String : String]) {
        
    }

    func vkTokenRemoved(for sessionId: String) {
    
    }
    
    func authVK(vkToken: String, userId: String) {
        DispatchQueue.main.sync { [weak self] in
            self?.acitivityIndicator.startAnimating()
        }
        
        NetworkManager.shared.authVK(userId: userId, vkToken: vkToken) { [weak self] response in
            self?.acitivityIndicator.stopAnimating()
            
            if let authVKResponse = response.value {
                self?.authVKReponse = authVKResponse
                
                if let accessToken = response.value?.tokens?.accessToken,
                    let refreshToken = response.value?.tokens?.refreshToken,
                    let uniqueSess = response.value?.uniqueSess,
                    let status = response.value?.status {
                    if status != ProfileStatus.clearuser.rawValue {
                        let user = UserData.init()
                        user.accessToken = accessToken
                        user.refreshToken = refreshToken
                        user.uniqueSess = uniqueSess
                        user.status = authVKResponse.status
                        user.save()

                        if let tokens = NotificationsTokens.loadSaved(),
                            let notificationToken = tokens.notificationToken,
                            let deviceToken = tokens.deviceToken {
                            NetworkManager.shared.sendNotificationToken(notificationToken: notificationToken,
                                                                        deviceToken: deviceToken,
                                                                        accessToken: accessToken) { response in
                                    if let vc = UIStoryboard(name: "Home", bundle: nil).instantiateInitialViewController() {
                                        vc.modalPresentationStyle = .fullScreen
                                        self?.present(vc, animated: true, completion: nil)
                                    }
                            }
                        }
                    } else {
                        if let tokens = NotificationsTokens.loadSaved(),
                            let notificationToken = tokens.notificationToken,
                            let deviceToken = tokens.deviceToken {
                            NetworkManager.shared.sendNotificationToken(notificationToken: notificationToken,
                                                                        deviceToken: deviceToken,
                                                                        accessToken: accessToken) { response in
                                self?.performSegue(withIdentifier: "seguePersonalData", sender: nil)
                            }
                        }
                    }
                }
            } else {
                self?.showAlert(message: NetworkErrors.common)
            }
        }
    }
}
