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
    @IBOutlet weak var nextButton: UIButton!
    
    lazy var imagePicker: ImagePicker = {
        return ImagePicker(presentationController: self, delegate: self)
    }()
    var isImageAdd: Bool = false
    var imagePath = ""
    
    let datePicker = UIDatePicker()

    var uniqueSess = ""
    var refreshToken = ""
    var accessToken = ""
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        toUniversityData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            dvc.imagePath = imagePath
            dvc.surname = lastnameTextField.text!
            dvc.name = firstnameTextField.text!
            dvc.patronymic = secondTextField.text!
            dvc.birthday = birthdayTextField.text!
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
            if let path = response.result.value?.path {
                self?.photoImageView.image = image
                self?.isImageAdd = true
                self?.photoImageView.layer.borderWidth = 0
                self?.imageErrorLabel.isHidden = true
                self?.imagePath = path
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
