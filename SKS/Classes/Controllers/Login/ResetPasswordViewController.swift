//
//  ResetPasswordViewController.swift
//  SKS
//
//  Created by Alexander on 09/01/2020.
//  Copyright © 2020 Katrych. All rights reserved.
//

import UIKit

protocol ResetPasswordViewControllerDelegate: class {
    func getOTP(otp: OtpResponse)
}

class ResetPasswordViewController: BaseViewController {
    @IBOutlet weak var firstTextField: UITextField!
    @IBOutlet weak var secondTextField: UITextField!
    @IBOutlet weak var thirdTextField: UITextField!
    @IBOutlet weak var fourthTextField: UITextField!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var bottomTimerLabelConstraint: NSLayoutConstraint!
    

    var keyboardHeight: CGFloat = 0
    
    var optString = ""
    var phone = ""
    var smsAttempt = ""
    weak var delegate: ResetPasswordViewControllerDelegate?
    
    var timeForLabel = 60
    var timer: Timer = Timer.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firstTextField.becomeFirstResponder()
        firstTextField.textAlignment = .center
        secondTextField.textAlignment = .center
        thirdTextField.textAlignment = .center
        fourthTextField.textAlignment = .center
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        
        bottomTimerLabelConstraint.constant = keyboardHeight + 16
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(timerLabelTapped))
        timerLabel.isUserInteractionEnabled = true
        timerLabel.addGestureRecognizer(tap)
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
            bottomTimerLabelConstraint.constant = keyboardHeight + 16
        }
    }
    
    @objc func timerLabelTapped() {
        if timeForLabel != 0 { return }
        getSmsWithCode()
    }
    
    private func getSmsWithCode() {
//        NetworkManager.shared.getCodeWithSms(phone: phone) { [weak self] response in
//            if response.result.error != nil {
//                self?.showAlert(message: NetworkErrors.common)
//            } else if let smsResponse = response.result.value {
//                
//                if let smsAttempt = smsResponse.attempt {
//                    self?.smsAttempt = smsAttempt
//                }
//                
//                self?.runTimer()
//            }
//        }
        
        NetworkManager.shared.resetPassword(phone: phone) { [weak self] response in
            if let smsResponse = response.value {
                if let smsAttempt = smsResponse.attempt {
                    self?.smsAttempt = smsAttempt
                }
                
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
                self.timerLabel.text = "Получить новый код еще раз"

            }
        }
    }
}

extension ResetPasswordViewController: UITextFieldDelegate {
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
           NetworkManager.shared.verifyCodeSms(phone: phone,
                                               attempt: smsAttempt,
                                               code: code) { [weak self] response in
            if let otpResponse = response.value {
                self?.delegate?.getOTP(otp: otpResponse)
                self?.navigationController?.popViewController(animated: true)
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
}
