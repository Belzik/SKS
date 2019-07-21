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
    @IBOutlet weak var lastnameTextField: ErrorTextField!
    @IBOutlet weak var firstnameTextField: ErrorTextField!
    @IBOutlet weak var secondTextField: ErrorTextField!
    @IBOutlet weak var birthdayTextField: ErrorTextField!
    @IBOutlet weak var nextButton: UIButton!
    
    lazy var imagePicker: ImagePicker = {
        return ImagePicker(presentationController: self, delegate: self)
    }()
    
    let datePicker = UIDatePicker()

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        toUniversityData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        //ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = false
        //toolBar.barTintColor = ColorManager.lightOrange.value
        toolBar.tintColor = .black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(doneDatePicker));
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
        toUniversityData()
    }
    
    @objc func cancelDatePicker() {
        view.endEditing(true)
    }
}

extension PersonalDataViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        if let image = image {
            photoImageView.image = image
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
