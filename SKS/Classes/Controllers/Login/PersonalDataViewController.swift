//
//  PersonalDataViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 19/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class PersonalDataViewController: BaseViewController {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var loaderPhoto: UIActivityIndicatorView!
    @IBOutlet weak var imageErrorLabel: UILabel!
    @IBOutlet weak var lastnameTextField: ErrorTextField!
    @IBOutlet weak var firstnameTextField: ErrorTextField!
    @IBOutlet weak var secondTextField: ErrorTextField!
    @IBOutlet weak var birthdayTextField: ErrorTextField!
    @IBOutlet weak var phoneTextField: ErrorTextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    lazy var imagePicker: ImagePicker = {
        return ImagePicker(presentationController: self, delegate: self)
    }()
    var isImageAdd: Bool = false
    var keyFile = ""
    
    let datePicker = UIDatePicker()

    var uniqueSess = ""
    var refreshToken = ""
    var accessToken = ""
    
    var possibleData: PossibleData?
    var isVK: Bool = false
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        toUniversityData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneTextField.textField.delegate = self
        phoneTextField.textField.keyboardType = .numberPad
        
        if let possibleData = possibleData {
            lastnameTextField.text = possibleData.surname
            firstnameTextField.text = possibleData.name
            birthdayTextField.text = possibleData.birthdate
        }
        
        if isVK {
            phoneTextField.isHidden = false
        } else {
            phoneTextField.isHidden = true
        }
        
        
        
        if UIDevice.modelName == "iPhone 5s" ||
            UIDevice.modelName ==  "iPhone SE" ||
            UIDevice.modelName ==  "Simulator iPhone SE" {
            let font = UIFont(name: "Montserrat-Bold", size: 20)!
            self.titleLabel.font = font
            
        }
        
        imageErrorLabel.text = """
        Загрузите свою
        фотографию
        """
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        photoImageView.isUserInteractionEnabled = true
        photoImageView.addGestureRecognizer(imageTap)
        
        photoImageView.makeCircular()
        setupDatePicker()
        lastnameTextField.delegate = self
        firstnameTextField.delegate = self
        secondTextField.delegate = self
//        birthdayTextField.delegate = self
        lastnameTextField.textField.returnKeyType = .next
        firstnameTextField.textField.returnKeyType = .next
        secondTextField.textField.returnKeyType = .next
        
        birthdayTextField.textField.rightView = UIImageView(image: UIImage(named: "ic_calendar"))
        birthdayTextField.textField.rightView?.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        birthdayTextField.textField.rightViewMode = .always
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueUniversityData" {
            let dvc = segue.destination as! UniversityDataViewController
            dvc.uniqueSess = uniqueSess
            dvc.refreshToken = refreshToken
            dvc.accessToken = accessToken
            dvc.keyFile = keyFile
            dvc.surname = lastnameTextField.text!
            dvc.name = firstnameTextField.text!
            dvc.patronymic = secondTextField.text!
            dvc.birthday = birthdayTextField.text!
            
            if isVK {
                let phone =  phoneTextField.text!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                dvc.phone = phone
            }
        }
    }
    
    @objc func imageTapped() {
        imagePicker.present(from: photoImageView)
    }
    
    func toUniversityData() {
        var isValid = true
        
        if lastnameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            lastnameTextField.errorMessage = "Поле не заполнено"
            isValid = false
        }
        
        if firstnameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            firstnameTextField.errorMessage = "Поле не заполнено"
            isValid = false
        }
        
        if birthdayTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            birthdayTextField.errorMessage = "Поле не заполнено"
            isValid = false
        }
        
        if isVK {
            if phoneTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                phoneTextField.errorMessage = "Поле не заполнено"
                isValid = false
            }
            
            if !phoneTextField.text!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined().isPhone() {
                phoneTextField.errorMessage = "Не верный формат телефона"
                isValid = false
            }
        }

        if !isImageAdd {
            imageErrorLabel.isHidden = false
            photoImageView.layer.borderColor = ColorManager.red.value.cgColor
            photoImageView.layer.borderWidth = 1
            isValid = false
        }
        
        if isValid {
            view.endEditing(true)
            performSegue(withIdentifier: "segueUniversityData", sender: nil)
        }
    }
    
    func setupDatePicker() {
        //Formate Date
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru")
        datePicker.backgroundColor = UIColor.white
        datePicker.maximumDate = Date()
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        
        //ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = false
        //toolBar.barTintColor = ColorManager.lightOrange.value
        toolBar.tintColor = .black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(doneDatePicker));
        doneButton.tintColor = ColorManager.green.value
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolBar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        
        birthdayTextField.textField.inputAccessoryView = toolBar
        birthdayTextField.textField.inputView = datePicker
        
    }
    
    @objc func doneDatePicker() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        birthdayTextField.text = formatter.string(from: datePicker.date)
        birthdayTextField.errorMessage = ""
        view.endEditing(true)
        //toUniversityData()
    }
    
    @objc func cancelDatePicker() {
        view.endEditing(true)
    }
}

extension PersonalDataViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        if let image = image {
            uploadImage(image: image)
        }
    }
    
    func uploadImage(image: UIImage) {
        loaderPhoto.startAnimating()
        NetworkManager.shared.uploadImage(image: image) { [weak self] response in
            self?.loaderPhoto.stopAnimating()
            if let keyFile = response.result.value?.keyFile {
                self?.photoImageView.image = image
                self?.isImageAdd = true
                self?.photoImageView.layer.borderWidth = 0
                self?.imageErrorLabel.isHidden = true
                self?.keyFile = keyFile
            } else {
                self?.showAlert(message: NetworkErrors.common)
            }
        }
    }
}

extension PersonalDataViewController: ErrorTextFieldDelegate {
    func nextTextField(errorTextField: ErrorTextField) {
        if let nextField = view.viewWithTag(errorTextField.tag + 1) as? ErrorTextField {
            nextField.textField.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
    }
}

extension PersonalDataViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == phoneTextField.textField {
            if textField.text == "" {
                textField.text = "+7 "
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneTextField.textField {
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
                       
                       //setupError(forTextField: textField as! SKSTextField, isDeleted: isDeleted)
                       return false
                   }
                   
                   //setupError(forTextField: textField as! SKSTextField, isDeleted: isDeleted)
                   return false
        }
       return true
    }
}
