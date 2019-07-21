//
//  UniversityDataViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 19/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class UniversityDataViewController: BaseViewController {
    @IBOutlet weak var cityTextField: ErrorTextField!
    @IBOutlet weak var instituteTextField: ErrorTextField!
    @IBOutlet weak var facultyTextField: ErrorTextField!
    @IBOutlet weak var specialtyTextField: ErrorTextField!
    @IBOutlet weak var startDateTextField: ErrorTextField!
    @IBOutlet weak var endDateTextField: ErrorTextField!
    @IBOutlet weak var courseTextField: ErrorTextField!
    
    private var institutePickerView: UIPickerView!
    private var institutePickerData = ["Институт 1" , "Институт 2" , "Институт 3" , "Институт 4"]
    
    private var facultyPickerView: UIPickerView!
    private var facultyPickerData = ["Факультет 1" , "Факультет 2" , "Факультет 3" , "Факультет 4"]
    
    private var specialtyPickerView: UIPickerView!
    private var specialtyPickerData = ["Специальность 1" , "Специальность 2" , "Специальность 3" , "Специальность 4"]
    
    private var coursePickerView: UIPickerView!
    private var coursePickerData = ["Курс 1" , "Курс 2" , "Курс 3" , "Курс 4", "Курс 5"]
    
    let startDatePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()
    
    @IBAction func nextButtonTapped() {
        validate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        cityTextField.delegate = self
        instituteTextField.delegate = self
        facultyTextField.delegate = self
        specialtyTextField.delegate = self
        startDateTextField.delegate = self
        endDateTextField.delegate = self
        courseTextField.delegate = self
        
        cityTextField.textField.returnKeyType = .next
        instituteTextField.textField.returnKeyType = .next
        facultyTextField.textField.returnKeyType = .next
        specialtyTextField.textField.returnKeyType = .next
        startDateTextField.textField.returnKeyType = .next
        endDateTextField.textField.returnKeyType = .next
        
        setupInstitutePicker()
        setupFacultyPicker()
        setupSpecialtyPicker()
        setupCoursePicker()
        setupStartDatePicker()
        setupEndDatePicker()
        
        facultyTextField.textField.isEnabled = false
        specialtyTextField.textField.isEnabled = false
    }

    func setupInstitutePicker() {
        // UIPickerView
        institutePickerView = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        institutePickerView.delegate = self
        institutePickerView.dataSource = self
        institutePickerView.selectRow(institutePickerData.count - 1, inComponent: 0, animated: false)
        institutePickerView.backgroundColor = .white
        
        instituteTextField.textField.inputView = institutePickerView
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = false
        //toolBar.barTintColor = ColorManager.lightOrange.value
        toolBar.tintColor = .black
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(doneInstitutePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(cancelPicker))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        instituteTextField.textField.inputAccessoryView = toolBar
    }
    
    func setupFacultyPicker() {
        // UIPickerView
        facultyPickerView = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        facultyPickerView.delegate = self
        facultyPickerView.dataSource = self
        facultyPickerView.selectRow(facultyPickerData.count - 1, inComponent: 0, animated: false)
        facultyPickerView.backgroundColor = .white
        
        facultyTextField.textField.inputView = facultyPickerView
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = false
        //toolBar.barTintColor = ColorManager.lightOrange.value
        toolBar.tintColor = .black
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(doneFacultyPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(cancelPicker))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        facultyTextField.textField.inputAccessoryView = toolBar
        
    }
    
    func setupSpecialtyPicker() {
        // UIPickerView
        specialtyPickerView = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        specialtyPickerView.delegate = self
        specialtyPickerView.dataSource = self
        specialtyPickerView.selectRow(specialtyPickerData.count - 1, inComponent: 0, animated: false)
        specialtyPickerView.backgroundColor = .white
        
        specialtyTextField.textField.inputView = specialtyPickerView
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = false
        //toolBar.barTintColor = ColorManager.lightOrange.value
        toolBar.tintColor = .black
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(doneSpecialtyPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(cancelPicker))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        specialtyTextField.textField.inputAccessoryView = toolBar
        
    }
    
    func setupCoursePicker() {
        // UIPickerView
        coursePickerView = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        coursePickerView.delegate = self
        coursePickerView.dataSource = self
        coursePickerView.selectRow(coursePickerData.count - 1, inComponent: 0, animated: false)
        coursePickerView.backgroundColor = .white
        
       courseTextField.textField.inputView = coursePickerView
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = false
        //toolBar.barTintColor = ColorManager.lightOrange.value
        toolBar.tintColor = .black
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(doneCoursePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(cancelPicker))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        courseTextField.textField.inputAccessoryView = toolBar
    }
    
    func setupStartDatePicker() {
        //Formate Date
        startDatePicker.datePickerMode = .date
        startDatePicker.locale = Locale(identifier: "ru")
        startDatePicker.backgroundColor = UIColor.white
        
        //ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = false
        //toolBar.barTintColor = ColorManager.lightOrange.value
        toolBar.tintColor = .black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(doneStartDatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(cancelPicker));
        
        toolBar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        
        startDateTextField.textField.inputAccessoryView = toolBar
        startDateTextField.textField.inputView = startDatePicker
        
    }
    
    func setupEndDatePicker() {
        //Formate Date
        endDatePicker.datePickerMode = .date
        endDatePicker.locale = Locale(identifier: "ru")
        endDatePicker.backgroundColor = UIColor.white
        
        //ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = false
        //toolBar.barTintColor = ColorManager.lightOrange.value
        toolBar.tintColor = .black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(doneEndDatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(cancelPicker));
        
        toolBar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        
        endDateTextField.textField.inputAccessoryView = toolBar
        endDateTextField.textField.inputView = endDatePicker
        
    }

    @objc func doneInstitutePicker() {
        if instituteTextField.text == "" {
            instituteTextField.text = institutePickerData.last
            instituteTextField.errorMessage = ""
            facultyTextField.textField.isEnabled = true
        }
        facultyTextField.textField.becomeFirstResponder()
    }
    
    @objc func doneFacultyPicker() {
        if facultyTextField.text == "" {
            facultyTextField.text = facultyPickerData.last
            facultyTextField.errorMessage = ""
            specialtyTextField.textField.isEnabled = true
        }
        specialtyTextField.textField.becomeFirstResponder()
    }
    
    @objc func doneSpecialtyPicker() {
        if specialtyTextField.text == "" {
            specialtyTextField.text = specialtyPickerData.last
            specialtyTextField.errorMessage = ""
        }
        startDateTextField.textField.becomeFirstResponder()
    }
    
    @objc func doneStartDatePicker() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        startDateTextField.text = formatter.string(from: startDatePicker.date)
        startDateTextField.errorMessage = ""
        endDateTextField.textField.becomeFirstResponder()
    }
    
    @objc func doneEndDatePicker() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        endDateTextField.text = formatter.string(from: endDatePicker.date)
        endDateTextField.errorMessage = ""
        courseTextField.textField.becomeFirstResponder()
    }
    
    @objc func doneCoursePicker() {
        if courseTextField.text == "" {
            courseTextField.text = coursePickerData.last
            courseTextField.errorMessage = ""
        }
        view.endEditing(true)
        validate()
    }
    
    @objc func cancelPicker() {
        view.endEditing(true)
    }
    
    func validate() {
        var isValid = true
        
        if cityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            cityTextField.errorMessage = "Поле не заполнено"
            isValid = false
        }
        
        if instituteTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            instituteTextField.errorMessage = "Поле не заполнено"
            isValid = false
        }
        
        if facultyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            facultyTextField.errorMessage = "Поле не заполнено"
            isValid = false
        }
        
        if specialtyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            specialtyTextField.errorMessage = "Поле не заполнено"
            isValid = false
        }
        
        if startDateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            startDateTextField.errorMessage = "Поле не заполнено"
            isValid = false
        }
        
        if endDateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            endDateTextField.errorMessage = "Поле не заполнено"
            isValid = false
        }
        
        if courseTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            courseTextField.errorMessage = "Поле не заполнено"
            isValid = false
        }
        
        view.endEditing(true)
//        if isValid {
//
//            //performSegue(withIdentifier: "segueUniversityData", sender: nil)
//        }
    }
}

extension UniversityDataViewController: ErrorTextFieldDelegate {
    func nextTextField(errorTextField: ErrorTextField) {
        if let nextField = view.viewWithTag(errorTextField.tag + 1) as? ErrorTextField {
            nextField.textField.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
    }
}

extension UniversityDataViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return institutePickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == institutePickerView {
            return institutePickerData[row]
        }
        
        if pickerView == facultyPickerView {
            return facultyPickerData[row]
        }
        
        if pickerView == specialtyPickerView {
            return specialtyPickerData[row]
        }
        
        if pickerView == coursePickerView {
            return coursePickerData[row]
        }
        
        return nil
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == institutePickerView {
            instituteTextField.text = institutePickerData[row]
            instituteTextField.errorMessage = ""
            facultyTextField.textField.isEnabled = true
        }

        if pickerView == facultyPickerView {
            facultyTextField.text = facultyPickerData[row]
            facultyTextField.errorMessage = ""
            specialtyTextField.textField.isEnabled = true
        }
        
        if pickerView == specialtyPickerView {
            specialtyTextField.text = specialtyPickerData[row]
            specialtyTextField.errorMessage = ""
        }
        
        if pickerView == coursePickerView {
            courseTextField.text = coursePickerData[row]
            courseTextField.errorMessage = ""
        }
    }
}
