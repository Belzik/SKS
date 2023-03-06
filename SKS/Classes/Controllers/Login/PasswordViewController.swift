//
//  PasswordViewController.swift
//  SKS
//
//  Created by Alexander on 09/01/2020.
//  Copyright © 2020 Katrych. All rights reserved.
//

import UIKit

class PasswordViewController: BaseViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var passwordTextField: SKSTextField!
    @IBOutlet weak var confimPasswordTextField: SKSTextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var resetErrorLabel: UILabel!
    @IBOutlet weak var nextButton: DownloadButton!
    
    // MARK: - Properties
    
    var otpResponse: OtpResponse?
    var smsResponse: SmsResponse?
    var setPassword: SetPasswordResponse?
    var isNewsUser = false
    var phone = ""
    
    var otpResponseReset: OtpResponse?
    var otpResponseSms: SmsResponse?
    var isResetPassword = false

    var isPromo: Bool = false
    var status: String = ""
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let status = otpResponse?.status {
            if ProfileStatus.newuser.rawValue == status {
                isNewsUser = true
            } else {
                isNewsUser = false
            }
        }
        
        if let status = smsResponse?.status {
            if ProfileStatus.newuser.rawValue == status {
                isNewsUser = true
            } else {
                isNewsUser = false
            }
        }
        
        if !isNewsUser {
            confimPasswordTextField.isHidden = true
        } else {
            resetPasswordButton.isHidden = true
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        passwordTextField.becomeFirstResponder()
    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seguePersonalData" {
            let dvc = segue.destination as! PersonalDataViewController
            
            if let uniqueSess = setPassword?.uniqueSess,
                let refreshToken = setPassword?.tokens?.refreshToken,
                let accessToken = setPassword?.tokens?.accessToken {
                dvc.uniqueSess = uniqueSess
                dvc.refreshToken = refreshToken
                dvc.accessToken = accessToken
                dvc.isPromo = isPromo

                if status == ProfileStatus.emptypromo.rawValue {
                    dvc.isPromo = true
                }
            }
        }
        
        if segue.identifier == "segueResetPassword" {
            let dvc = segue.destination as! ResetPasswordViewController
            dvc.delegate = self
            dvc.phone = phone
            if let attempt = smsResponse?.attempt {
                dvc.smsAttempt = attempt
            }
        }
    }
    
    // MARK: - Methods
    
    private func setPasswordUser() {
        if let text = passwordTextField.text,
            let textRepeat = confimPasswordTextField.text {
            if text != textRepeat {
                resetErrorLabel.text = "Пароли не совпадают"
                //resetErrorLabel.isHidden = false
                passwordTextField.selectedLineColor = ColorManager.red.value
                passwordTextField.lineColor = ColorManager.red.value
                passwordTextField.tintColor = ColorManager.red.value
                
                confimPasswordTextField.selectedLineColor = ColorManager.red.value
                confimPasswordTextField.lineColor = ColorManager.red.value
                confimPasswordTextField.tintColor = ColorManager.red.value
                return
            }
            
            if text.count < 4 {
                //showAlert(message: "Слишком короткий пароль")
                passwordErrorLabel.text = "Слишком короткий пароль"
                passwordErrorLabel.isHidden = false
                passwordTextField.selectedLineColor = ColorManager.red.value
                passwordTextField.lineColor = ColorManager.red.value
                passwordTextField.tintColor = ColorManager.red.value
                passwordTextField.becomeFirstResponder()
                return
            }
        }
        
        guard let passwordKey = otpResponse?.setPasswordKey,
            let password = passwordTextField.text else { return }
            
        nextButton.isDownload = true
        NetworkManager.shared.setPassword(passwordKey: passwordKey,
                                           password: password) { [weak self] response in
            defer { self?.nextButton.isDownload = false }
            if let setPassword = response.value {
                self?.setPassword = setPassword
                self?.performSegue(withIdentifier: "seguePersonalData", sender: nil)
            } else {
                self?.showAlert(message: NetworkErrors.common)
            }
        }
   }
    
     private func resetPasswordUser() {
         if let text = passwordTextField.text,
             let textRepeat = confimPasswordTextField.text {
             if text != textRepeat {
                 //showAlert(message: "Пароли не совпадают")
                
                resetErrorLabel.text = "Пароли не совпадают"
                //resetErrorLabel.isHidden = false
                passwordTextField.selectedLineColor = ColorManager.red.value
                passwordTextField.lineColor = ColorManager.red.value
                passwordTextField.tintColor = ColorManager.red.value
                
                confimPasswordTextField.selectedLineColor = ColorManager.red.value
                confimPasswordTextField.lineColor = ColorManager.red.value
                confimPasswordTextField.tintColor = ColorManager.red.value
                
                 return
             }
             
             if text.count < 4 {
                 //showAlert(message: "Слишком короткий пароль")
                passwordErrorLabel.text = "Слишком короткий пароль"
                passwordErrorLabel.isHidden = false
                passwordTextField.selectedLineColor = ColorManager.red.value
                passwordTextField.lineColor = ColorManager.red.value
                passwordTextField.tintColor = ColorManager.red.value
                passwordTextField.becomeFirstResponder()
                 return
             }
         }
         
         guard let passwordKey = otpResponseReset?.setPasswordKey,
             let password = passwordTextField.text else { return }
             
        nextButton.isDownload = true
         NetworkManager.shared.setPassword(passwordKey: passwordKey,
                                            password: password) { [weak self] response in
            defer { self?.nextButton.isDownload = false }
            if let setPassword = response.value {
                self?.setPassword = setPassword
                                self?.setPassword = setPassword
                if let accessToken = response.value?.tokens?.accessToken,
                    let refreshToken = response.value?.tokens?.refreshToken,
                    let uniqueSess = response.value?.uniqueSess,
                    let status = response.value?.status {
                    if status != ProfileStatus.clearuser.rawValue {
                        let user = UserData.init()
                        user.accessToken = accessToken
                        user.refreshToken = refreshToken
                        user.uniqueSess = uniqueSess
                        user.status = setPassword.status
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
    
//    if errorMessage == "" {
//        textField.selectedLineColor = ColorManager.green.value
//        textField.lineColor = ColorManager.gray.value
//    } else {
//        textField.selectedLineColor = ColorManager.red.value
//        textField.lineColor = ColorManager.red.value
//    }
    
    private func auth() {
        if let text = passwordTextField.text {
            if text.count < 4 {
                //showAlert(message: "Слишком короткий пароль")
                passwordErrorLabel.text = "Слишком короткий пароль"
                passwordErrorLabel.isHidden = false
                passwordTextField.selectedLineColor = ColorManager.red.value
                passwordTextField.lineColor = ColorManager.red.value
                passwordTextField.tintColor = ColorManager.red.value
                return
            }
        }
        
        guard let loginKey = smsResponse?.loginKey,
                let password = passwordTextField.text else { return }

        nextButton.isDownload = true
        NetworkManager.shared.enterPassword(loginKey: loginKey,
                                            password: password) { [weak self] response in
            defer { self?.nextButton.isDownload = false }
            
            guard let responseCode = response.responseCode else {
                self?.showAlert(message: "Пожалуйста, получите пароль.")
                return
            }

            if responseCode == 401 {
                self?.passwordErrorLabel.text = "Не верный пароль"
                self?.passwordErrorLabel.isHidden = false
                self?.passwordTextField.selectedLineColor = ColorManager.red.value
                self?.passwordTextField.lineColor = ColorManager.red.value
                self?.passwordTextField.tintColor = ColorManager.red.value
                self?.passwordTextField.text = ""
            } else if responseCode == 200,
                      let setPassword = response.value {
                self?.setPassword = setPassword

                if let status = response.value?.status {
                    self?.status = status
                }

                if let accessToken = response.value?.tokens?.accessToken,
                    let refreshToken = response.value?.tokens?.refreshToken,
                    let uniqueSess = response.value?.uniqueSess,
                    let status = response.value?.status {
                    if status != ProfileStatus.clearuser.rawValue &&
                        status != ProfileStatus.emptypromo.rawValue {
                        let user = UserData.init()
                        user.accessToken = accessToken
                        user.refreshToken = refreshToken
                        user.uniqueSess = uniqueSess
                        user.status = setPassword.status
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
    
//    private auth() {
//
//    }
    
    // MARK: - Actions
    
    @IBAction func nextButtonTapped(_ sender: DownloadButton) {
        if isResetPassword {
            resetPasswordUser()
            return
        }

        if isNewsUser {
            setPasswordUser()
        } else {
            auth()
        }
    }
    
    @IBAction func resetPasswordButtonTapped(_ sender: UIButton) {
        let rsaData = RSAService.shared.generateAnEncryptedString()
        NetworkManager.shared.resetPassword(
            phone: phone,
            verifyKey: rsaData.verifyKey,
            key: rsaData.key
        ) { [weak self] response in
            if let smsResponse = response.value {
                    self?.smsResponse = smsResponse
                    self?.performSegue(withIdentifier: "segueResetPassword", sender: nil)
            } else {
                self?.showAlert(message: NetworkErrors.common)
            }
        }
    }
    
}

// MARK: - ResetPasswordViewControllerDelegate
 
extension PasswordViewController: ResetPasswordViewControllerDelegate {
    func getOTP(otp: OtpResponse) {
        isResetPassword = true
        otpResponseReset = otp
        resetPasswordButton.isHidden = true
        confimPasswordTextField.isHidden = false
        
        //passwordErrorLabel.isHidden = true
        passwordErrorLabel.text = ""
        passwordTextField.text = ""
        
        passwordTextField.selectedLineColor = ColorManager.green.value
        passwordTextField.lineColor = ColorManager.gray.value
        passwordTextField.tintColor = ColorManager.green.value
    }
}

// MARK: - UITextFieldDelegate

extension PasswordViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == passwordTextField {
            if passwordErrorLabel.isHidden == false {
                //passwordErrorLabel.isHidden = true
                
                passwordErrorLabel.text = ""
                passwordTextField.selectedLineColor = ColorManager.green.value
                passwordTextField.lineColor = ColorManager.gray.value
                passwordTextField.tintColor = ColorManager.green.value
                
                passwordTextField.selectedLineColor = ColorManager.green.value
                passwordTextField.lineColor = ColorManager.gray.value
                passwordTextField.tintColor = ColorManager.green.value
            }
        }
        
        if textField == confimPasswordTextField {
            if resetErrorLabel.isHidden == false {
                //resetErrorLabel.isHidden = true
                
                resetErrorLabel.text = ""
                confimPasswordTextField.selectedLineColor = ColorManager.green.value
                confimPasswordTextField.lineColor = ColorManager.gray.value
                confimPasswordTextField.tintColor = ColorManager.green.value
                
                passwordTextField.selectedLineColor = ColorManager.green.value
                passwordTextField.lineColor = ColorManager.gray.value
                passwordTextField.tintColor = ColorManager.green.value
            }
        }
        
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordTextField {
            if confimPasswordTextField.isHidden == false {
                confimPasswordTextField.becomeFirstResponder()
            } else {
                view.endEditing(true)
            }
        }

        if textField == confimPasswordTextField {
            view.endEditing(true)
        }

        return true
    }
}
