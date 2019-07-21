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
    
    var timeForLabel = 20
    var timer: Timer = Timer.init()

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
        timeForLabel = 20
        timerLabel.textColor = UIColor.gray
        runTimer()
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
        
        if isDeleted {
            if let nextField = self.view.viewWithTag(textField.tag - 1) as? UITextField,
                !nextField.isHidden {
                let oldText = textField.text
                textField.text = newString
                
                if oldText?.count == 0 {
                    nextField.becomeFirstResponder()
                }
                
                return false
            }
        } else {
            if let nextField = self.view.viewWithTag(textField.tag + 1) as? UITextField,
                !nextField.isHidden {
                
                if newString.count < 2 {
                    textField.text = newString
                }
                //textField.text = newString
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
    
    func sendCode() {
        if !(firstTextField.text! == "") &&
            !(secondTextField.text! == "") &&
            !(thirdTextField.text! == "") &&
            !(fourthTextField.text! == "") {
            performSegue(withIdentifier: "seguePersonalData", sender: nil)
        }
    }
}
