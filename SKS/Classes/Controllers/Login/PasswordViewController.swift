//
//  PasswordViewController.swift
//  SKS
//
//  Created by Alexander on 09/01/2020.
//  Copyright © 2020 Katrych. All rights reserved.
//

import UIKit

class PasswordViewController: BaseViewController {
    @IBOutlet weak var passwordTextField: SKSTextField!
    @IBOutlet weak var confimPasswordTextField: SKSTextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var resetErrorLabel: UILabel!
    
    var otpResponse: OtpResponse?
    var smsResponse: SmsResponse?
    var setPassword: SetPasswordResponse?
    var isNewsUser = false
    var phone = ""
    
    var otpResponseReset: OtpResponse?
    var otpResponseSms: SmsResponse?
    var isResetPassword = false
    
    @IBAction func nextButtonTapped(_ sender: SKSButton) {
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
        NetworkManager.shared.resetPassword(phone: phone) { [weak self] response in
            if let smsResponse = response.value {
                    self?.smsResponse = smsResponse
                    self?.performSegue(withIdentifier: "segueResetPassword", sender: nil)
            } else {
                self?.showAlert(message: NetworkErrors.common)
            }
        }
    }
    
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seguePersonalData" {
            let dvc = segue.destination as! PersonalDataViewController
            
            if let uniqueSess = setPassword?.uniqueSess,
                let refreshToken = setPassword?.tokens?.refreshToken,
                let accessToken = setPassword?.tokens?.accessToken {
                dvc.uniqueSess = uniqueSess
                dvc.refreshToken = refreshToken
                dvc.accessToken = accessToken
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
            
        NetworkManager.shared.setPassword(passwordKey: passwordKey,
                                           password: password) { [weak self] response in
            
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
             
         NetworkManager.shared.setPassword(passwordKey: passwordKey,
                                            password: password) { [weak self] response in
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
             
        NetworkManager.shared.enterPassword(loginKey: loginKey,
                                            password: password) { [weak self] response in
            if let setPassword = response.value {
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
            } else if let statusCode = response.responseCode {
                if statusCode == 401 {
                    self?.passwordErrorLabel.text = "Не верный пароль"
                    self?.passwordErrorLabel.isHidden = false
                    self?.passwordTextField.selectedLineColor = ColorManager.red.value
                    self?.passwordTextField.lineColor = ColorManager.red.value
                    self?.passwordTextField.tintColor = ColorManager.red.value
                    self?.passwordTextField.text = ""
                } else {
                    self?.showAlert(message: NetworkErrors.common)
                }
            } else {
                self?.showAlert(message: "Пожалуйста, получите пароль.")
            }
        }
    }
}

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
}
