//
//  ViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 29/06/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class LoginViewController: BaseViewController {
    @IBOutlet weak var phoneTextField: SKSTextField!
    @IBOutlet weak var nextButton: SKSButton!
    @IBOutlet weak var agreementsLabel: UILabel!
    @IBOutlet weak var bottomConstraintAgreementLabel: NSLayoutConstraint!
    
    private var keyboardHeight: CGFloat = 0
    
    @IBAction func nextbuttonTapped(_ sender: SKSButton) {
        getSmsWithCode()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let stringValue = "Нажимая кнопку \"Далее\", я соглашаюсь с Пользовательски соглашением и Политикой конфиденциальности"
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: stringValue)
        attributedString.setColorForText(textForAttribute: "Пользовательски соглашением", withColor: ColorManager.green.value)
        attributedString.setColorForText(textForAttribute: "Политикой конфиденциальности", withColor: ColorManager.green.value)
        
        agreementsLabel.attributedText = attributedString
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        phoneTextField.becomeFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueCode" {
            let dvc = segue.destination as! CodeViewController
            dvc.keyboardHeight = keyboardHeight
        }
    }

    func test() {
        NetworkManager.shared.getContent { (response) in
            print("----------------------------------")
            switch response.result {
            case .success(let string):
                print(string)
            case .failure(let error):
                print(error)
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
    
    private func getSmsWithCode() {
        NetworkManager.shared.getCodeWithSms(phone: phoneTextField.text!) { [weak self] result in
            if let error = result.error {
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                let alert = UIAlertController(title: "Внимание", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(action)
                
                //7
                //self?.present(alert, animated: true, completion: nil)
            } else {
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                let alert = UIAlertController(title: "Внимание", message: "Смска успешно отправлена", preferredStyle: .alert)
                alert.addAction(action)
                
                //self?.present(alert, animated: true, completion: nil)
            }
        }
        
        performSegue(withIdentifier: "segueCode", sender: nil)
    }
    
    private func setupError(forTextField textField: SKSTextField) {
        if textField == phoneTextField {
                if !phoneTextField.text!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined().isPhone() {
                    //phoneTextField.errorMessage = "Некорректный телефон"
                    phoneTextField.selectedLineColor = ColorManager.green.value
                    //nextButton.backgroundColor = UIColor.gray
                    phoneTextField.rightViewMode = .never
                    nextButton.isHidden = true
                    agreementsLabel.isHidden = true
                } else {
                    //phoneTextField.errorMessage = ""
                    //nextButton.backgroundColor = ColorManager.green.value
                    phoneTextField.selectedLineColor = UIColor.gray
                    phoneTextField.rightView = UIImageView(image: UIImage(named: "check"))
                    phoneTextField.rightView?.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
                    phoneTextField.rightViewMode = .always
                    nextButton.isHidden = false
                    agreementsLabel.isHidden = false
    
//
                }
        }
    }
    
    
    func formattedNumber(number: String) -> String {
        let result = stringWithMask(text: number,
                                    formattingPattern: "+* (***) ***-**-**",
                                    replacementChar: "*",
                                    isDecimalDigits: true)
        
        return result
    }

    func stringWithMask(text: String, formattingPattern: String, replacementChar: Character, isDecimalDigits: Bool) -> String {
        if text.count > 0 && formattingPattern.count > 0 {
            let tempString = isDecimalDigits ? text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined() : text.components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
            
            var finalText = ""
            var stop = false
            
            var formatterIndex = formattingPattern.startIndex
            var tempIndex = tempString.startIndex
            
            while !stop {
                let formattingPatternRange = formatterIndex..<formattingPattern.index(formatterIndex, offsetBy: 1)
                
                if formattingPattern.substring(with: formattingPatternRange) != String(replacementChar) {
                    finalText = finalText.appendingFormat(formattingPattern.substring(with: formattingPatternRange))
                } else if tempString.count > 0 {
                    let pureStringRange = tempIndex..<tempString.index(tempIndex, offsetBy: 1)
                    finalText = finalText.appendingFormat(tempString.substring(with: pureStringRange))
                    tempIndex = tempString.index(tempIndex, offsetBy: 1)
                }
                
                formatterIndex = formattingPattern.index(formatterIndex, offsetBy: 1)
                
                if formatterIndex >= formattingPattern.endIndex || tempIndex >= tempString.endIndex {
                    stop = true
                }
            }
            
            stop = false
            while !stop {
                if formatterIndex >= formattingPattern.endIndex {
                    stop = true
                    break
                }
                
                if formattingPattern[formatterIndex] == replacementChar {
                    stop = true
                } else {
                    finalText += String(formattingPattern[formatterIndex])
                    formatterIndex = formattingPattern.index(formatterIndex, offsetBy: 1)
                }
            }
            
            return finalText
        }
        return ""
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setupError(forTextField: textField as! SKSTextField)
        
        if textField == phoneTextField {
            if textField.text == "" {
                textField.text = "+7"
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        let isDeleted = newString.count < textField.text!.count
        
        if textField == phoneTextField &&
            !isDeleted {
            
            textField.text = formattedNumber(number: newString)
            setupError(forTextField: textField as! SKSTextField)
            return false
        }
        
        textField.text = newString
        setupError(forTextField: textField as! SKSTextField)
        return false
    }
}
