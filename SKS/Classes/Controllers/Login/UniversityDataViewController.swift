//
//  UniversityDataViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 19/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class UniversityDataViewController: BaseViewController {
    // MARK: - Views

    @IBOutlet weak var cityTextField: ErrorTextField!
    @IBOutlet weak var instituteTextField: ErrorTextField!
    @IBOutlet weak var facultyTextField: ErrorTextField!
    @IBOutlet weak var periodTextField: ErrorTextField!
    @IBOutlet weak var courseTextField: ErrorTextField!
    @IBOutlet weak var levelEducationTextField: ErrorTextField!
    @IBOutlet weak var dateEndTextField: ErrorTextField!
    @IBOutlet weak var titleLabel: UILabel!

    // MARK: - Properties

    var cityPicker: SKSPicker = SKSPicker()
    var institutePicker: SKSPicker = SKSPicker()
    var facultyPicker: SKSPicker = SKSPicker()
    
    var periodPicker: PeriodPicker = PeriodPicker()
    var coursePicker: SKSPicker = SKSPicker()
    var levelsPicker: SKSPicker = SKSPicker()
    var dateEndPicker: PeriodPicker = PeriodPicker()
    
    var cities: [City] = []
    var universities: [University] = []
    var faculties: [Faculty] = []
    
    var courses: [Course] = [
        Course(title: "1 курс", value: "1"),
        Course(title: "2 курс", value: "2"),
        Course(title: "3 курс", value: "3"),
        Course(title: "4 курс", value: "4"),
        Course(title: "5 курс", value: "5"),
        Course(title: "6 курс", value: "6")
    ]
    var levels: [LevelEducation] = [
        LevelEducation(title: "Бакалавр", value: "4"),
        LevelEducation(title: "Специалитет", value: "5"),
        LevelEducation(title: "Магистратура", value: "2"),
        LevelEducation(title: "Аспирантура", value: "6"),
    ]
    
    var uniqueSess = ""
    var refreshToken = ""
    var accessToken = ""
    var keyFile = ""
    var surname = ""
    var name = ""
    var patronymic = ""
    var birthday = ""
    var phone = ""
    
    var startEducation = ""
    var endEducation = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.modelName == "iPhone 5s" ||
            UIDevice.modelName ==  "iPhone SE" ||
            UIDevice.modelName ==  "Simulator iPhone SE" {
            let font = UIFont(name: "Montserrat-Bold", size: 20)!
            self.titleLabel.font = font
            
        }

        setupTextFields()
        setupPickers()
        getCities()
    }
    
    func setupTextFields() {
        instituteTextField.textField.isEnabled = false
        facultyTextField.textField.isEnabled = false
        periodTextField.textField.isEnabled = false
        
        setupImageTextField(textField: cityTextField.textField)
        setupImageTextField(textField: instituteTextField.textField)
        setupImageTextField(textField: facultyTextField.textField)
        //setupImageTextField(textField: courseTextField.textField)
        setupImageTextField(textField: levelEducationTextField.textField)
        setupImageTextField(textField: periodTextField.textField)
        
        dateEndTextField.textField.isUserInteractionEnabled = false
        courseTextField.textField.isUserInteractionEnabled = false
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
        
        periodPicker.delegate = self
        periodTextField.textField.inputAccessoryView = periodPicker.toolBar
        periodTextField.textField.inputView = periodPicker.picker
        
        coursePicker.delegate = self
        courseTextField.textField.inputAccessoryView = coursePicker.toolBar
        courseTextField.textField.inputView = coursePicker.picker
        coursePicker.source = courses
        
        levelsPicker.delegate = self
        levelEducationTextField.textField.inputAccessoryView = levelsPicker.toolBar
        levelEducationTextField.textField.inputView = levelsPicker.picker
        levelsPicker.source = levels
        
        dateEndPicker.delegate = self
        dateEndTextField.textField.inputAccessoryView = dateEndPicker.toolBar
        dateEndTextField.textField.inputView = dateEndPicker.picker
    }
    
    func getCities() {
        NetworkManager.shared.getСityUniversities { [weak self] response in
            if let cities = response.value,
                cities.count > 0 {
                self?.cityPicker.source = cities
                self?.cities = cities
            }
        }
    }
    
    func getInstitutions() {
        let uuidCity = cities[cityPicker.picker.selectedRow(inComponent: 0)].uuidCity
        
        NetworkManager.shared.getUniversities(uuidCity: uuidCity ?? "") { [weak self] response in
            if let universities = response.value,
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
            if let faculties = response.value,
                faculties.count > 0 {
                self?.facultyPicker.source = faculties
                self?.faculties = faculties
                self?.facultyTextField.textField.isEnabled = true
                self?.facultyTextField.textField.becomeFirstResponder()
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
        
        if periodTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            periodTextField.errorMessage = "Поле не заполнено"
            isValid = false
        }
        
        if levelEducationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            levelEducationTextField.errorMessage = "Поле не заполнено"
            isValid = false
        }
        
        
        if dateEndTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            dateEndTextField.errorMessage = "Поле не заполнено"
            isValid = false
        }
        
        
        if courseTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            courseTextField.errorMessage = "Поле не заполнено"
            isValid = false
        }
        
        
        return isValid
    }

    // MARK: - Actions

    @IBAction func nextButtonTapped() {
        if validate() {
            let uuidCity = cities[cityPicker.picker.selectedRow(inComponent: 0)].uuidCity
            let uuidUniversity = universities[institutePicker.picker.selectedRow(inComponent: 0)].uuidUniver
            let uuidFaculty = faculties[facultyPicker.picker.selectedRow(inComponent: 0)].uuidDepartment

            NetworkManager.shared.registration(uniqueSess: uniqueSess,
                                               name: name,
                                               patronymic: patronymic,
                                               surname: surname,
                                               birthdate: birthday,
                                               startEducation: periodTextField.text!,
                                               endEducation: dateEndTextField.text!,
                                               course: courseTextField.text!,
                                               uuidCity: uuidCity ?? "",
                                               uuidUniversity: uuidUniversity,
                                               uuidFaculty: uuidFaculty,
                                               accessToken: accessToken,
                                               keyPhoto: keyFile,
                                               phone: phone) { [weak self] response in
                if let user = response.value,
                        user.uuidUser != nil {
                    user.accessToken = self?.accessToken
                    user.refreshToken = self?.refreshToken
                    user.uniqueSess = self?.uniqueSess
                    user.save()

                    if let vc = UIStoryboard(name: "Home", bundle: nil).instantiateInitialViewController() {
                        vc.modalPresentationStyle = .fullScreen
                        self?.present(vc, animated: true, completion: nil)
                    }
                } else {
                    self?.showAlert(message: NetworkErrors.common)
                }
            }
        }
    }
}

extension UniversityDataViewController: SKSPickerDelegate {
    func donePicker(picker: SKSPicker, value: TypeOfSourcePicker) {
        if picker == cityPicker {
            cityTextField.text = value.title
            
            instituteTextField.textField.isEnabled = false
            facultyTextField.textField.isEnabled = false
            
            instituteTextField.textField.text = ""
            facultyTextField.textField.text = ""
            
            getInstitutions()
        }
        
        if picker == institutePicker {
            instituteTextField.text = value.title
            
            facultyTextField.textField.isEnabled = false
            
            facultyTextField.textField.text = ""
            
            getFaculties()
        }
        
        if picker == facultyPicker {
            facultyTextField.text = value.title

            levelEducationTextField.textField.becomeFirstResponder()
        }
        
        if picker == levelsPicker {
            periodTextField.textField.isEnabled = true
            
            
            levelEducationTextField.text = value.title
            let value = levels[levelsPicker.picker.selectedRow(inComponent: 0)].value
            
            if let value = Int(value) {
                periodPicker.setupPicker(levelValue: value)
            }
            
//            if periodTextField.text! != "" {
//                if let dateStart = periodTextField.text,
//                    let dateStartInt = Int(dateStart),
//                    let intValue = Int(value) {
//                    dateEndTextField.text = String(describing: (dateStartInt + intValue))
//                }
//
//            }
//
//            if let intValue = Int(value) {
//
//            }
            periodTextField.text = ""
            dateEndTextField.text = ""
            courseTextField.text = ""
            
            periodTextField.textField.becomeFirstResponder()
            dateEndTextField.textField.isUserInteractionEnabled = false
            //view.endEditing(true)
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
    func donePicker(dateStart: String, periodPicker: PeriodPicker) {
        if periodPicker == self.periodPicker {
            let title = levels[levelsPicker.picker.selectedRow(inComponent: 0)].title
            
            if title == "Аспирантура" {
                startEducation = dateStart

                periodTextField.text = "\(dateStart)"
                    
                let value = levels[levelsPicker.picker.selectedRow(inComponent: 0)].value

                if let value = Int(value) {
                    dateEndPicker.setupPicker(levelValue: value, isInverted: true)
                }
                
                if let currentYear = Int(Date().year),
                let dateStart = periodTextField.text,
                let dateStartInt = Int(dateStart) {
                    var course = currentYear - dateStartInt
                    
                    if let currentMonth = Int(Date().month) {
                        if currentMonth >= 9 {
                            course += 1
                        }
                    }

                    courseTextField.text = String(describing: course)
                }

                dateEndTextField.textField.isUserInteractionEnabled = true
                dateEndTextField.textField.becomeFirstResponder()
            } else {
                dateEndTextField.textField.isUserInteractionEnabled = false
                startEducation = dateStart

                periodTextField.text = "\(dateStart)"

                if levelEducationTextField.text! != "" {
                    let value = levels[levelsPicker.picker.selectedRow(inComponent: 0)].value

                    if let dateStart = periodTextField.text,
                    let dateStartInt = Int(dateStart),
                    let intValue = Int(value) {
                        let dateEnd = dateStartInt + intValue
                        dateEndTextField.text = String(describing: dateEnd)

                    }

                }

                if let currentYear = Int(Date().year),
                let dateStart = periodTextField.text,
                let dateStartInt = Int(dateStart) {
                    var course = currentYear - dateStartInt
                    
                    if let currentMonth = Int(Date().month) {
                        if currentMonth >= 9 {
                            course += 1
                        }
                    }

                    courseTextField.text = String(describing: course)
                }


                view.endEditing(true)
            }
        }
        
        if periodPicker == dateEndPicker {
            dateEndTextField.text = dateStart
            view.endEditing(true)
        }
    }
}
