//
//  ViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 29/06/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit
import SwiftyVK
import AuthenticationServices

class LoginViewController: BaseViewController {
    // MARK: IBOutlets

    @IBOutlet weak var phoneTextField: SKSTextField!
    @IBOutlet weak var nextButton: DownloadButton!
    @IBOutlet weak var agreementsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var acitivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var authVKButton: TitleWithIconButton!
    @IBOutlet weak var authAppleButton: TitleWithIconButton!
    @IBOutlet weak var promoCodeRegistrationButton: DownloadButton!
    @IBOutlet weak var stackButtons: UIStackView!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var loginsButtonStack: UIStackView!
    @IBOutlet weak var nextButtonView: UIView!

    // MARK: Properties

    private var keyboardHeight: CGFloat = 0
    private var smsResponse: SmsResponse?
    var authVKReponse: AuthVKResponse?
    var givenName: String? = ""
    var familyName: String? = ""
    var isPromo: Bool = false
    var promocode: String = ""
    
    // MARK: View life cycle
    
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
        setupButtons()

        if isPromo {
            promoCodeRegistrationButton.isHidden = true
            orLabel.isHidden = true
            loginsButtonStack.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        phoneTextField.becomeFirstResponder()
    }
     // MARK: Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueCode" {
            let dvc = segue.destination as! CodeViewController
            dvc.keyboardHeight = keyboardHeight
            dvc.phone = phoneTextField.text!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            dvc.isPromo = isPromo
            dvc.promocode = promocode
                
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
                dvc.givenName = givenName
                dvc.familyName = familyName

                if let _ = sender as? Bool {} else {
                    dvc.possibleData = authVKReponse?.possibleData
                    dvc.isVK = true
                }
            }
        }
    }
    
    // MARK: Methods

    private func setupButtons() {
        authVKButton.titleLabel.text = "Вход с Вконтакте"
        authVKButton.backgroundColor = ColorManager._0077FF.value
        authVKButton.layer.cornerRadius = 5
        authVKButton.iconView.image = UIImage(named: "authVK")

        let tapVK = UITapGestureRecognizer(target: self, action: #selector(authVKButtonTapped))
        authVKButton.isUserInteractionEnabled = true
        authVKButton.addGestureRecognizer(tapVK)

        authAppleButton.titleLabel.text = "Вход с Apple"
        authAppleButton.backgroundColor = ColorManager._090E16.value
        authAppleButton.layer.cornerRadius = 5
        authAppleButton.iconView.image = UIImage(named: "authApple")

        let tapApple = UITapGestureRecognizer(target: self, action: #selector(authAppleButtonTapped))
        authAppleButton.isUserInteractionEnabled = true
        authAppleButton.addGestureRecognizer(tapApple)

        promoCodeRegistrationButton.layer.cornerRadius = 5
    }
    
    private func setupAgreementsLabel() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(agreementsLabelTapped))
        agreementsLabel.isUserInteractionEnabled = true
        agreementsLabel.addGestureRecognizer(tap)
    }

    private func getSmsWithCode() {
        nextButton.isDownload = true
        NetworkManager.shared.getCodeWithSms(
            phone: phoneTextField.text!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(),
            isPromo: isPromo,
            promocode: promocode
        ) { [weak self] response in
                guard let self = self else { return }

            if let smsResponse = response.value {
                self.smsResponse = smsResponse

                if let error = smsResponse.error {
                    self.showAlert(message: error)
                } else if let loginKey = smsResponse.loginKey,
                    loginKey == "" {
                    self.performSegue(withIdentifier: "segueCode", sender: nil)
                } else {
                    if self.isPromo {
                        self.showAlert(message: "Пользователь уже существует.")
                    } else {
                        self.performSegue(withIdentifier: "seguePassword", sender: nil)
                    }
                }
            } else {
                self.showAlert(message: NetworkErrors.common)
            }
                self.nextButton.isDownload = false
        }
    }
    
    private func views(hide: Bool) {
        UIView.transition(with: view, duration: 0.2, options: .transitionCrossDissolve, animations: {
            //self.view.layoutIfNeeded()
            self.authVKButton.isHidden = !hide
            self.authAppleButton.isHidden = !hide
            self.promoCodeRegistrationButton.isHidden = !hide
            if !self.isPromo {
                self.loginsButtonStack.isHidden = !hide
            }
            self.nextButtonView.isHidden = hide
            self.nextButton.isHidden = hide
            self.agreementsLabel.isHidden = hide
            self.phoneTextField.rightView?.isHidden = hide


//            if hide {
//                let bottomOffset = CGPoint(x: 0, y: 0)
//                self.scrollView.setContentOffset(bottomOffset, animated: true)
//            } else {
//                let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.size.height)
//                self.scrollView.setContentOffset(bottomOffset, animated: true)
//            }
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

    // MARK: - Actions

    @objc func agreementsLabelTapped() {
        performSegue(withIdentifier: "segueAgreements", sender: nil)
    }

    @IBAction override func backButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func nextbuttonTapped(_ sender: DownloadButton) {
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

    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height

            if keyboardHeight > 0 {
                //bottonConstraint.constant = keyboardHeight - 40
                self.keyboardHeight = keyboardHeight
            } else {
                //bottonConstraint.constant = 0
            }
        }
    }

    @objc func authAppleButtonTapped() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email, .fullName]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    @objc func authVKButtonTapped() {
        VK.sessions.default.logOut()

        VK.sessions.default.logIn(
            onSuccess: { _ in

            },
            onError: { error in

            }
        )
    }
}

// MARK: UITextFieldDelegate

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
                
                guard let startPosition = textField.position(from: textField.beginningOfDocument, offset: cursorLocation) else {
                    setupError(forTextField: textField as! SKSTextField, isDeleted: isDeleted)
                    return false

                }
                guard let endPosition = textField.position(from: startPosition, offset: 0) else {
                    setupError(forTextField: textField as! SKSTextField, isDeleted: isDeleted)
                    return false
                }
                textField.selectedTextRange = textField.textRange(from: startPosition, to: endPosition)
            }
            
//            setupError(forTextField: textField as! SKSTextField, isDeleted: isDeleted)
//            return false
        }
        
        setupError(forTextField: textField as! SKSTextField, isDeleted: isDeleted)
        return false
    }
}

// MARK: SwiftyVKDelegate

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

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {

        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            print("Apple КРЕДЕНТЫ", appleIDCredential.fullName)
            self.givenName = appleIDCredential.fullName?.givenName
            self.familyName = appleIDCredential.fullName?.familyName
            NetworkManager.shared.authApple(
                userId: appleIDCredential.user,
                email: appleIDCredential.email ?? "m6wndgpzd4@privaterelay.appleid.com") { [weak self] response in
                self?.acitivityIndicator.stopAnimating()

                if let authVKResponse = response.value {
                    self?.authVKReponse = authVKResponse

                    if let accessToken = response.value?.tokens?.accessToken,
                        let refreshToken = response.value?.tokens?.refreshToken,
                        let uniqueSess = response.value?.uniqueSess,
                        let status = response.value?.status {
                        if status != ProfileStatus.newuser.rawValue {
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
                                    self?.performSegue(withIdentifier: "seguePersonalData", sender: true)
                                }
                            }
                        }
                    }
                } else {
                    self?.showAlert(message: NetworkErrors.common)
                }
                }
        default:
            break
        }
    }
}
