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
    
    var keyboardHeight: CGFloat = 0
    var smsAttempt: String = ""
    var phone: String = ""
    
    var timeForLabel = 120
    var timer: Timer = Timer.init()
    
    var uniqueSess = ""
    var refreshToken = ""
    var accessToken = ""
    
    var optString = ""

    override func viewDidLoad() {
        super.viewDidLoad()

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
        if segue.identifier == "seguePersonalData" {
            let dvc = segue.destination as! PersonalDataViewController
            dvc.uniqueSess = uniqueSess
            dvc.refreshToken = refreshToken
            dvc.accessToken = accessToken
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
        timeForLabel = 120
        timerLabel.textColor = UIColor.gray
        getSmsWithCode()
    }
    
    private func getSmsWithCode() {
        NetworkManager.shared.getCodeWithSms(phone: phone) { [weak self] response in
            if response.result.error != nil {
                self?.showAlert(message: NetworkErrors.common)
            } else if let attempt = response.result.value?.attempt {
                self?.smsAttempt = attempt
                self?.runTimer()
            }
        }
    }
    
    func runTimer() {
        timerLabel.text = "Отправить код еще раз через \(timeForLabel) сек"
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [unowned self] timer in
            self.timeForLabel -= 1
            self.timerLabel.text = "Отправить код еще раз через \(self.timeForLabel) сек"
            
            if self.timeForLabel == 0 {
                self.timer.invalidate()
                self.timerLabel.textColor = ColorManager.green.value
                self.timerLabel.text = "Отправить код ещё раз"

            }
        }
    }
}

extension CodeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        let isDeleted = newString.count < textField.text!.count
        
        optString += newString
        print(optString)
        if optString.count == 6 {
            
            print(newString[0...0])
            print(newString[1...1])
            print(newString[3...3])
            print(newString[5...5])
            firstTextField.text = optString[0...0]
            secondTextField.text = optString[1...1]
            thirdTextField.text = optString[3...3]
            fourthTextField.text = optString[5...5]
            sendCode()
            return false
        }
        
        if isDeleted {
            if let prevTextField = self.view.viewWithTag(textField.tag - 1) as? UITextField {
                textField.text = newString
                prevTextField.becomeFirstResponder()
                return false
            } else {
                textField.text = newString
                return false
            }
        } else {
            if let nextField = self.view.viewWithTag(textField.tag + 1) as? UITextField,
                !nextField.isHidden {
                
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
            !(fourthTextField.text! == "") {
            
            let code = firstTextField.text! + secondTextField.text! + thirdTextField.text! + fourthTextField.text!
            verifyCode(code: code)
        }
    }
    
    private func verifyCode(code: String) {
        NetworkManager.shared.verifyCodeSms(phone: phone,
                                            attempt: smsAttempt,
                                            code: code) { [weak self] response in
            if response.result.error != nil,
                let statusCode = response.statusCode {
                
                if statusCode == 403 {
                    self?.firstTextField.becomeFirstResponder()
                    self?.showAlert(message: "Неверный код sms, либо истекло действие кода.")
                    self?.firstTextField.text! = ""
                    self?.secondTextField.text! = ""
                    self?.thirdTextField.text! = ""
                    self?.fourthTextField.text! = ""
                } else {
                    self?.showAlert(message: NetworkErrors.common)
                }
            } else if let accessToken = response.result.value?.tokens?.accessToken,
                        let refreshToken = response.result.value?.tokens?.refreshToken,
                        let uniqueSess = response.result.value?.uniqueSess,
                        let status = response.result.value?.status {
                if status != ProfileStatus.newuser.rawValue {
                    let user = UserData.init()
                    user.accessToken = accessToken
                    user.refreshToken = refreshToken
                    user.uniqueSess = uniqueSess
                    user.save()
                    
                    if let vc = UIStoryboard(name: "Home", bundle: nil).instantiateInitialViewController() {
                        self?.present(vc, animated: true, completion: nil)
                    }
                } else {
                    self?.accessToken = accessToken
                    self?.uniqueSess = uniqueSess
                    self?.refreshToken = refreshToken
                    self?.performSegue(withIdentifier: "seguePersonalData", sender: nil)
                }

            }
        }
    }
}
