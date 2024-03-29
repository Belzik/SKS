//
//  CodeViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 19/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class CodeViewController: BaseViewController {
    @IBOutlet weak var firstTextField: UITextField!
    @IBOutlet weak var secondTextField: UITextField!
    @IBOutlet weak var thirdTextField: UITextField!
    @IBOutlet weak var fourthTextField: UITextField!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var bottomConstraintTimerLabel: NSLayoutConstraint!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var keyboardHeight: CGFloat = 0
    var smsResponse: SmsResponse!
    var phone: String = ""
    
    var timeForLabel = 60
    var timer: Timer = Timer.init()
    
    var uniqueSess = ""
    var refreshToken = ""
    var accessToken = ""
    
    var optString = ""
    
    var otpResponse: OtpResponse?

    var isPromo: Bool = false
    var promocode: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        if UIDevice.modelName == "iPhone 5s" ||
            UIDevice.modelName ==  "iPhone SE" ||
            UIDevice.modelName ==  "Simulator iPhone SE" {
            let font = UIFont(name: "Montserrat-Bold", size: 20)!
            self.titleLabel.font = font
            
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        firstTextField.becomeFirstResponder()
        firstTextField.textAlignment = .center
        secondTextField.textAlignment = .center
        thirdTextField.textAlignment = .center
        fourthTextField.textAlignment = .center
        
        bottomConstraintTimerLabel.constant = keyboardHeight + 16
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(timerLabelTapped))
        timerLabel.isUserInteractionEnabled = true
        timerLabel.addGestureRecognizer(tap)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seguePassword" {
            let dvc = segue.destination as! PasswordViewController
            dvc.otpResponse = self.otpResponse
            dvc.isPromo = isPromo
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        runTimer()
    }
    

    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            bottomConstraintTimerLabel.constant = keyboardHeight + 16
        }
    }
    
    @objc func timerLabelTapped() {
        if timeForLabel != 0 { return }
        getSmsWithCode()
    }
    
    private func getSmsWithCode() {
        let rsaData = RSAService.shared.generateAnEncryptedString()
        NetworkManager.shared.getCodeWithSms(
            phone: phone,
            isPromo: isPromo,
            promocode: promocode,
            key: rsaData.key,
            verifyKey: rsaData.verifyKey
        ) { [weak self] response in
            
            if let smsResponse = response.value {
                self?.smsResponse = smsResponse

                if let error = smsResponse.error {
                    self?.showAlert(message: error)
                } else {
                    self?.timeForLabel = 60
                    self?.timerLabel.textColor = UIColor.gray
                    self?.runTimer()
                }
            } else {
                self?.showAlert(message: NetworkErrors.common)
            }
        }
    }
    
    func runTimer() {
        timerLabel.text = "Получить новый код можно через \(timeForLabel) сек"
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }

            self.timeForLabel -= 1
            self.timerLabel.text = "Получить новый код можно через \(self.timeForLabel) сек"
            
            if self.timeForLabel == 0 {
                self.timer.invalidate()
                self.timerLabel.textColor = ColorManager.green.value
                self.timerLabel.text = "Получить код еще раз"
            }
        }
    }
}

extension CodeViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
//        if textField == secondTextField {
            if textField.text == "" &&
                textField != firstTextField {
                textField.font = UIFont.systemFont(ofSize: 0)
                textField.text = "*"
            }
        
        if textField == firstTextField {
            textField.tintColor = .clear
            textField.font = UIFont.systemFont(ofSize: 0)
        }
  //      }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        let isDeleted = newString.count < textField.text!.count
        
        let font = UIFont(name: "Montserrat-Bold", size: 20)!
        textField.font = font
        newString = newString.replacingOccurrences(of: "*", with: "")
        
        optString += newString
        if optString.count == 6 {
            firstTextField.text = optString[0...0]
            secondTextField.text = optString[1...1]
            thirdTextField.text = optString[3...3]
            fourthTextField.text = optString[5...5]
            sendCode()
            return false
        }
        
        if isDeleted {
            optString.removeLast()
            if let prevTextField = self.view.viewWithTag(textField.tag - 1) as? UITextField {
                
                if textField.text!.count == 1 {
                    prevTextField.text = ""
                    prevTextField.isUserInteractionEnabled = true
                    textField.font =  UIFont.systemFont(ofSize: 0)
                } else {
                    textField.text = newString
                    
                }
                
                
                prevTextField.becomeFirstResponder()
                return false
            } else {
                textField.text = newString
                return false
            }
        } else {
            if let nextField = self.view.viewWithTag(textField.tag + 1) as? UITextField,
                !nextField.isHidden {
                textField.isUserInteractionEnabled = false

                if newString.count < 2 {
                    textField.text = newString
                }
                
                nextField.becomeFirstResponder()
                sendCode()
                return false
            }
            
        }
        
        if textField == fourthTextField {
            if newString.count == 1 {
                
                if newString.count < 2 {
                    textField.text = newString
                }
                
                
            }
        }
        sendCode()
        return false
    }
    
    private func sendCode() {
        if !(firstTextField.text! == "") &&
            !(secondTextField.text! == "") &&
            !(thirdTextField.text! == "") &&
            !(fourthTextField.text! == "") &&
            !(firstTextField.text! == "*") &&
            !(secondTextField.text! == "*") &&
            !(thirdTextField.text! == "*") &&
            !(fourthTextField.text! == "*"){
            
            let code = firstTextField.text! + secondTextField.text! + thirdTextField.text! + fourthTextField.text!
            verifyCode(code: code)
        }
    }
    
    private func verifyCode(code: String) {
           guard let smsAttempt = smsResponse.attempt else { return }
           
           NetworkManager.shared.verifyCodeSms(phone: phone,
                                               attempt: smsAttempt,
                                               code: code) { [weak self] response in
            if let otpResponse = response.value {
                 self?.otpResponse = otpResponse
                 self?.performSegue(withIdentifier: "seguePassword", sender: nil)
            } else if let statusCode = response.responseCode {
                if statusCode == 403 {
                    self?.firstTextField.isUserInteractionEnabled = true
                    self?.secondTextField.isUserInteractionEnabled = true
                    self?.thirdTextField.isUserInteractionEnabled = true
                    //self?errorLabel.isHidden = false
                    self?.firstTextField.becomeFirstResponder()
                    self?.showAlert(message: "Неверный код sms, либо истекло действие кода.")
                    self?.firstTextField.text! = ""
                    self?.secondTextField.text! = ""
                    self?.thirdTextField.text! = ""
                    self?.fourthTextField.text! = ""
                    self?.optString = ""
                } else {
                     self?.firstTextField.isUserInteractionEnabled = true
                     self?.secondTextField.isUserInteractionEnabled = true
                     self?.thirdTextField.isUserInteractionEnabled = true
                     self?.firstTextField.becomeFirstResponder()
                 
                    self?.showAlert(message: NetworkErrors.common)
                 
                     self?.firstTextField.text! = ""
                     self?.secondTextField.text! = ""
                     self?.thirdTextField.text! = ""
                     self?.fourthTextField.text! = ""
                     self?.optString = ""
                }
            }
       }
    }
    
//    private func verifyCode(code: String) {
//        guard let smsAttempt = smsResponse.attempt else { return}
//
//        NetworkManager.shared.verifyCodeSms(phone: phone,
//                                            attempt: smsAttempt,
//                                            code: code) { [weak self] response in
//            if response.result.error != nil,
//                let statusCode = response.statusCode {
//
//                if statusCode == 403 {
//                    self?.firstTextField.isUserInteractionEnabled = true
//                    self?.secondTextField.isUserInteractionEnabled = true
//                    self?.thirdTextField.isUserInteractionEnabled = true
//                    //self?errorLabel.isHidden = false
//                    self?.firstTextField.becomeFirstResponder()
//                    self?.showAlert(message: "Неверный код sms, либо истекло действие кода.")
//                    self?.firstTextField.text! = ""
//                    self?.secondTextField.text! = ""
//                    self?.thirdTextField.text! = ""
//                    self?.fourthTextField.text! = ""
//                    self?.optString = ""
//                } else {
//                    self?.showAlert(message: NetworkErrors.common)
//                }
//            } else if let accessToken = response.result.value?.tokens?.accessToken,
//                        let refreshToken = response.result.value?.tokens?.refreshToken,
//                        let uniqueSess = response.result.value?.uniqueSess,
//                        let status = response.result.value?.status {
//                if status != ProfileStatus.newuser.rawValue {
//                    let user = UserData.init()
//                    user.accessToken = accessToken
//                    user.refreshToken = refreshToken
//                    user.uniqueSess = uniqueSess
//                    user.save()
//
//                    if let tokens = NotificationsTokens.loadSaved(),
//                        let notificationToken = tokens.notificationToken,
//                        let deviceToken = tokens.deviceToken {
//                        NetworkManager.shared.sendNotificationToken(notificationToken: notificationToken,
//                                                                    deviceToken: deviceToken,
//                                                                    accessToken: accessToken) { response in
//                                if let vc = UIStoryboard(name: "Home", bundle: nil).instantiateInitialViewController() {
//                                    vc.modalPresentationStyle = .fullScreen
//                                    self?.present(vc, animated: true, completion: nil)
//                                }
//                        }
//                    }
//
//
//                } else {
//                    self?.accessToken = accessToken
//                    self?.uniqueSess = uniqueSess
//                    self?.refreshToken = refreshToken
//
//                    if let tokens = NotificationsTokens.loadSaved(),
//                        let notificationToken = tokens.notificationToken,
//                        let deviceToken = tokens.deviceToken {
//                        NetworkManager.shared.sendNotificationToken(notificationToken: notificationToken,
//                                                                    deviceToken: deviceToken,
//                                                                    accessToken: accessToken) { response in
//                            self?.performSegue(withIdentifier: "seguePersonalData", sender: nil)
//                        }
//                    }
//
//
//                }
//
//            }
//        }
//    }
}
