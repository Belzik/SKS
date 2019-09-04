//
//  ViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 29/06/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

        //UIApplication.statusBarBackgroundColor = UIColor(hexString: "#383C45")
//application.statusBarStyle = .lightContent

class LoginViewController: BaseViewController {
    @IBOutlet weak var phoneTextField: SKSTextField!
    @IBOutlet weak var nextButton: SKSButton!
    @IBOutlet weak var agreementsLabel: UILabel!
    @IBOutlet weak var bottomConstraintAgreementLabel: NSLayoutConstraint!
    
    private var keyboardHeight: CGFloat = 0
    private var smsAttempt: String = ""
    
    @IBAction override func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextbuttonTapped(_ sender: SKSButton) {
        getSmsWithCode()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            dvc.smsAttempt = smsAttempt
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
            if response.result.error != nil {
                self?.showAlert(message: NetworkErrors.common)
            } else if let attempt = response.result.value?.attempt {
                self?.smsAttempt = attempt
                self?.performSegue(withIdentifier: "segueCode", sender: nil)
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
        
        if textField == phoneTextField &&
            !isDeleted {
            
            textField.text = newString.with(mask: "+* (***) ***-**-**", replacementChar: "*", isDecimalDigits: true)
            setupError(forTextField: textField as! SKSTextField, isDeleted: isDeleted)
            return false
        }
        
        textField.text = newString
        setupError(forTextField: textField as! SKSTextField, isDeleted: isDeleted)
        return false
    }
}
