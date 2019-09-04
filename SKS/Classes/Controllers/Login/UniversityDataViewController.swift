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
    @IBOutlet weak var periodTextField: ErrorTextField!
    @IBOutlet weak var courseTextField: ErrorTextField!
    
    var cityPicker: SKSPicker = SKSPicker()
    var institutePicker: SKSPicker = SKSPicker()
    var facultyPicker: SKSPicker = SKSPicker()
    var specialityPicker: SKSPicker = SKSPicker()
    var periodPicker: PeriodPicker = PeriodPicker()
    var coursePicker: SKSPicker = SKSPicker()
    
    var cities: [City] = []
    var universities: [University] = []
    var faculties: [Faculty] = []
    var specialties: [Specialty] = []
    var courses: [Course] = [
        Course(title: "1 курс", value: "1"),
        Course(title: "2 курс", value: "2"),
        Course(title: "3 курс", value: "3"),
        Course(title: "4 курс", value: "4"),
        Course(title: "5 курс", value: "5"),
        Course(title: "6 курс", value: "6")
    ]
    
    var uniqueSess = ""
    var refreshToken = ""
    var accessToken = ""
    var imagePath = ""
    var surname = ""
    var name = ""
    var patronymic = ""
    var birthday = ""
    
    var startEducation = ""
    var endEducation = ""
    
    @IBAction func nextButtonTapped() {
        if validate() {
            let course = courses[coursePicker.picker.selectedRow(inComponent: 0)].value
            let uuidCity = cities[cityPicker.picker.selectedRow(inComponent: 0)].uuidCity
            let uuidUniversity = universities[institutePicker.picker.selectedRow(inComponent: 0)].uuidUniver
            let uuidFaculty = faculties[facultyPicker.picker.selectedRow(inComponent: 0)].uuidDepartment
            let uuidSpecialty = specialties[specialityPicker.picker.selectedRow(inComponent: 0)].uuidSpecialty
            
            NetworkManager.shared.registration(uniqueSess: uniqueSess,
                                               name: name,
                                               patronymic: patronymic,
                                               surname: surname,
                                               birthdate: birthday,
                                               startEducation: startEducation,
                                               endEducation: endEducation,
                                               course: course,
                                               uuidCity: uuidCity ?? "",
                                               photo: imagePath,
                                               uuidUniversity: uuidUniversity,
                                               uuidFaculty: uuidFaculty,
                                               uuidSpecialty: uuidSpecialty,
                                               accessToken: accessToken) { [weak self] response in
                if let user = response.result.value {
                    user.accessToken = self?.accessToken
                    user.refreshToken = self?.refreshToken
                    user.uniqueSess = self?.uniqueSess
                    user.save()
                    
                    if let vc = UIStoryboard(name: "Home", bundle: nil).instantiateInitialViewController() {
                        self?.present(vc, animated: true, completion: nil)
                    }
                } else {
                    print(response.result.error)
                    self?.showAlert(message: NetworkErrors.common)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTextFields()
        setupPickers()
        getCities()
    }
    
    func setupTextFields() {
        instituteTextField.textField.isEnabled = false
        facultyTextField.textField.isEnabled = false
        specialtyTextField.textField.isEnabled = false
        
        setupImageTextField(textField: cityTextField.textField)
        setupImageTextField(textField: instituteTextField.textField)
        setupImageTextField(textField: facultyTextField.textField)
        setupImageTextField(textField: specialtyTextField.textField)
        setupImageTextField(textField: courseTextField.textField)
    }
    
    func setupImageTextField(textField: UITextField) {
        let textFieldCGRect = CGRect(x: 0, y: 0, width: 24, height: 24)
        let textFieldImage = UIImage(named: "ic_arrow_down")
        
        textField.rightView = UIImageView(image: textFieldImage)
        textField.rightView?.frame = textFieldCGRect
        textField.rightViewMode = .always
    }
    
    func setupPickers() {
        cityPicker.delegate = self
        cityTextField.textField.inputAccessoryView = cityPicker.toolBar
        cityTextField.textField.inputView = cityPicker.picker
        
        institutePicker.delegate = self
        instituteTextField.textField.inputAccessoryView = institutePicker.toolBar
        instituteTextField.textField.inputView = institutePicker.picker
        
        facultyPicker.delegate = self
        facultyTextField.textField.inputAccessoryView = facultyPicker.toolBar
        facultyTextField.textField.inputView = facultyPicker.picker
        
        specialityPicker.delegate = self
        specialtyTextField.textField.inputAccessoryView = specialityPicker.toolBar
        specialtyTextField.textField.inputView = specialityPicker.picker
        
        periodPicker.delegate = self
        periodTextField.textField.inputAccessoryView = periodPicker.toolBar
        periodTextField.textField.inputView = periodPicker.picker
        
        coursePicker.delegate = self
        courseTextField.textField.inputAccessoryView = coursePicker.toolBar
        courseTextField.textField.inputView = coursePicker.picker
        coursePicker.source = courses
    }
    
    func getCities() {
        NetworkManager.shared.getСityUniversities { [weak self] response in
            if let cities = response.result.value,
                cities.count > 0 {
                self?.cityPicker.source = cities
                self?.cities = cities
            }
        }
    }
    
    func getInstitutions() {
        let uuidCity = cities[cityPicker.picker.selectedRow(inComponent: 0)].uuidCity
        
        NetworkManager.shared.getUniversities(uuidCity: uuidCity ?? "") { [weak self] response in
            if let universities = response.result.value,
                universities.count > 0 {
                self?.institutePicker.source = universities
                self?.universities = universities
                self?.instituteTextField.textField.isEnabled = true
                self?.instituteTextField.textField.becomeFirstResponder()
            }
        }
    }
    
    func getFaculties() {
        let uuidUniver = universities[institutePicker.picker.selectedRow(inComponent: 0)].uuidUniver
        
        NetworkManager.shared.getFaculties(uuidUniver: uuidUniver) { [weak self] response in
            if let faculties = response.result.value,
                faculties.count > 0 {
                self?.facultyPicker.source = faculties
                self?.faculties = faculties
                self?.facultyTextField.textField.isEnabled = true
                self?.facultyTextField.textField.becomeFirstResponder()
            }
        }
    }
    
    func getSpecialties() {
        let uuidFaculty = faculties[facultyPicker.picker.selectedRow(inComponent: 0)].uuidDepartment
        
        NetworkManager.shared.getSpecialties(uuidFaculty: uuidFaculty) { [weak self] response in
            if let specialties = response.result.value,
                specialties.count > 0 {
                self?.specialityPicker.source = specialties
                self?.specialties = specialties
                self?.specialtyTextField.textField.isEnabled = true
                self?.specialtyTextField.textField.becomeFirstResponder()
            }
        }
    }
    
    func validate() -> Bool {
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
        
        if periodTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            periodTextField.errorMessage = "Поле не заполнено"
            isValid = false
        }
        
        
        if courseTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            courseTextField.errorMessage = "Поле не заполнено"
            isValid = false
        }
        
        return isValid
    }
}

extension UniversityDataViewController: SKSPickerDelegate {
    func donePicker(picker: SKSPicker, value: TypeOfSourcePicker) {
        if picker == cityPicker {
            cityTextField.text = value.title
            
            instituteTextField.textField.isEnabled = false
            facultyTextField.textField.isEnabled = false
            specialtyTextField.textField.isEnabled = false
            
            instituteTextField.textField.text = ""
            facultyTextField.textField.text = ""
            specialtyTextField.textField.text = ""
            
            getInstitutions()
        }
        
        if picker == institutePicker {
            instituteTextField.text = value.title
            
            facultyTextField.textField.isEnabled = false
            specialtyTextField.textField.isEnabled = false
            
            facultyTextField.textField.text = ""
            specialtyTextField.textField.text = ""
            
            getFaculties()
        }
        
        if picker == facultyPicker {
            facultyTextField.text = value.title
            
            specialtyTextField.textField.isEnabled = false
            specialtyTextField.textField.text = ""
            
            getSpecialties()
        }
        
        if picker == specialityPicker {
            specialtyTextField.text = value.title
            periodTextField.textField.becomeFirstResponder()
        }
        
        if picker == coursePicker {
            courseTextField.text = value.title
            view.endEditing(true)
        }
    }
    
    func cancelPicker() {
        view.endEditing(true)
    }
}

extension UniversityDataViewController: PeriodPickerDelegate {
    func donePicker(dateStart: String, dateEnd: String) {
        startEducation = dateStart
        endEducation = dateEnd
        
        periodTextField.text = "\(dateStart) - \(dateEnd)"
        courseTextField.textField.becomeFirstResponder()
    }
}
