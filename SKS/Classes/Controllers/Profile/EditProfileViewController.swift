//
//  EditProfileViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 05/09/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class LevelEducation: TypeOfSourcePicker {
    var title: String
    var value: String
    
    init(title: String, value: String) {
        self.title = title
        self.value = value
    }
}

class EditProfileViewController: BaseViewController {
    @IBOutlet weak var navbarView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var lastnameTextField: ErrorTextField!
    @IBOutlet weak var firstnameTextField: ErrorTextField!
    @IBOutlet weak var secondTextField: ErrorTextField!
    @IBOutlet weak var birthdayTextField: ErrorTextField!
    @IBOutlet weak var phoneTextField: ErrorTextField!
    
    @IBOutlet weak var cityTextField: ErrorTextField!
    @IBOutlet weak var instituteTextField: ErrorTextField!
    @IBOutlet weak var facultyTextField: ErrorTextField!
    @IBOutlet weak var levelEducationTextField: ErrorTextField!
    @IBOutlet weak var periodTextField: ErrorTextField!
    @IBOutlet weak var dateEndTextField: ErrorTextField!
    @IBOutlet weak var courseTextField: ErrorTextField!
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        if validate() {
            
            NetworkManager.shared.updateUserInfo(uniqueSess: uniqueSess,
                                                 name: firstnameTextField.text!,
                                                 patronymic: secondTextField.text!,
                                                 surname: lastnameTextField.text!,
                                                 birthdate: birthdayTextField.text!,
                                                 startEducation: periodTextField.text!,
                                                 endEducation: dateEndTextField.text!,
                                                 course: courseTextField.text!,
                                                 uuidCity: uuidCity,
                                                 photo: photo,
                                                 uuidUniversity: uuidUniversity,
                                                 uuidFaculty: uuidFaculty,
                                                 phone: phoneTextField.text!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) { [weak self] response in
                if let statusCode = response.statusCode,
                    statusCode == 200 {
                    let action = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                        self?.navigationController?.popViewController(animated: true)
                    }
                    self?.showAlert(actions: [action], title: "Внимание", message: "Данные успешно обновлены.")
                } else {
                    self?.showAlert(message: NetworkErrors.common)
                }
            }
        }
    }
    
    @IBAction func exitButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    var user: UserData!
    
    lazy var imagePicker: ImagePicker = {
        return ImagePicker(presentationController: self, delegate: self)
    }()
    
    var cityPicker: SKSPicker = SKSPicker()
    var institutePicker: SKSPicker = SKSPicker()
    var facultyPicker: SKSPicker = SKSPicker()
    var periodPicker: PeriodPicker = PeriodPicker()
    var levelsPicker: SKSPicker = SKSPicker()
    var coursePicker: SKSPicker = SKSPicker()
    
    let datePicker = UIDatePicker()
    
    var cities: [City] = []
    var universities: [University] = []
    var faculties: [Faculty] = []
    var levels: [LevelEducation] = [
        LevelEducation(title: "Бакалавр", value: "4"),
        LevelEducation(title: "Специалитет", value: "5"),
        LevelEducation(title: "Магистратура", value: "2")
//        LevelEducation(title: "Аспирантура", value: "6")
    ]
    
    var isFirstLoad = true
    var dispatchGroup = DispatchGroup()
    
    var uniqueSess: String = ""
    var uuidCity: String = ""
    var photo: String = ""
    var uuidUniversity: String = ""
    var uuidFaculty: String = ""
    var accessToken: String = ""
    var startEducation: String = ""
    var endEducation: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        photoImageView.isUserInteractionEnabled = true
        photoImageView.addGestureRecognizer(imageTap)

        
        phoneTextField.textField.delegate = self
        phoneTextField.textField.keyboardType = .numberPad
        if let isVk = user.vk,
            isVk {
            phoneTextField.isHidden = false
        } else {
            phoneTextField.isHidden = true
        }
        
        lastnameTextField.delegate = self
        firstnameTextField.delegate = self
        secondTextField.delegate = self
        
        setupImageTextField(textField: cityTextField.textField)
        setupImageTextField(textField: instituteTextField.textField)
        setupImageTextField(textField: facultyTextField.textField)
        setupImageTextField(textField: levelEducationTextField.textField)
        dateEndTextField.textField.isUserInteractionEnabled = false
        courseTextField.textField.isUserInteractionEnabled = false
        
        setupDatePicker()
        setupPickers()
        fillData()
        loadData()
    }
    
    @objc func imageTapped() {
        imagePicker.present(from: photoImageView)
    }

    func fillData() {
        uniqueSess = user.uniqueSess ?? ""
        uuidCity = user.studentInfo?.uuidCity ?? ""
        photo = user.studentInfo?.photo ?? ""
        uuidUniversity = user.studentInfo?.uuidUniversity ?? ""
        uuidFaculty = user.studentInfo?.uuidFaculty ?? ""
        accessToken = user.accessToken ?? ""
        startEducation = user.studentInfo?.startEducation ?? ""
        endEducation = user.studentInfo?.endEducation ?? ""
        
        photoImageView.makeCircular()
        if let photoPath = user.studentInfo?.photo,
            let url = URL(string: photoPath) {
            photoImageView.kf.setImage(with: url)
        }
        
        lastnameTextField.text = user.studentInfo?.surname
        firstnameTextField.text = user.studentInfo?.name
        secondTextField.text = user.studentInfo?.patronymic
        birthdayTextField.text = user.studentInfo?.birthdate
        
        cityTextField.text = user.studentInfo?.nameCity
        instituteTextField.text = user.studentInfo?.nameUniversity
        facultyTextField.text = user.studentInfo?.nameFaculty
        
        periodTextField.text = user.studentInfo?.startEducation
        dateEndTextField.text = user.studentInfo?.endEducation
        
        if let dateSt = user.studentInfo?.startEducation,
            let dateEnd = user.studentInfo?.endEducation,
            let dateStInt = Int(dateSt),
            let dateEndInt = Int(dateEnd){
            let diff = dateEndInt - dateStInt
            
            for (index, level) in levels.enumerated() {
                if let value = Int(level.value),
                    value == diff {
                    levelEducationTextField.text = level.title
                    levelsPicker.picker.selectRow(index,
                                                  inComponent: 0,
                                                  animated: false)
                }
            }
        }
        
        if let course = user.studentInfo?.course { courseTextField.text = String(describing: course) }
        
        if let dateString = user.studentInfo?.birthdate,
            let date = DateManager.shared.toDate(dateString: dateString) {
            datePicker.date = date
        }
    }
    
    func setupImageTextField(textField: UITextField) {
        let textFieldCGRect = CGRect(x: 0, y: 0, width: 24, height: 24)
        let textFieldImage = UIImage(named: "ic_arrow_down")
        
        textField.rightView = UIImageView(image: textFieldImage)
        textField.rightView?.frame = textFieldCGRect
        textField.rightViewMode = .always
    }
    
    func loadData() {
        navbarView.isHidden = true
        scrollView.isHidden = true
        
        activityIndicator.startAnimating()
        getCities()
        
        getInstitutions()

        getFaculties()

        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.navbarView.isHidden = false
            self?.scrollView.isHidden = false
            self?.isFirstLoad = false
            self?.activityIndicator.stopAnimating()
        }
    }
    
    func getCities() {
        dispatchGroup.enter()
        NetworkManager.shared.getСityUniversities { [weak self] response in
            self?.dispatchGroup.leave()
            if let cities = response.result.value,
                cities.count > 0 {
                self?.cityPicker.source = cities
                self?.cities = cities
                
                if let city = self?.user.studentInfo?.nameCity {
                    for (index, value) in cities.enumerated() {
                        if let nameCity = value.nameCity {
                            if nameCity == city {
                                 self?.cityPicker.picker.selectRow(index,
                                                                   inComponent: 0,
                                                                   animated: false)
                             }
                        }
                    }
                }
            }
        }
    }
    
    func getInstitutions() {
        dispatchGroup.enter()
        NetworkManager.shared.getUniversities(uuidCity: uuidCity) { [unowned self] response in
            self.dispatchGroup.leave()
            if let universities = response.result.value,
                universities.count > 0 {
                self.institutePicker.source = universities
                self.universities = universities
                self.instituteTextField.textField.isEnabled = true
                
                if !self.isFirstLoad {
                    self.instituteTextField.textField.becomeFirstResponder()
                }
                
                if self.isFirstLoad {
                    if let univer = self.user.studentInfo?.nameUniversity {
                        for (index, value) in universities.enumerated() {
                            if value.nameUniver == univer {
                                self.institutePicker.picker.selectRow(index,
                                                                      inComponent: 0,
                                                                      animated: false)
                             }
                        }
                    }
                }
            }
        }
    }
    
    func getFaculties() {
        dispatchGroup.enter()
        NetworkManager.shared.getFaculties(uuidUniver: uuidUniversity) { [unowned self] response in
            self.dispatchGroup.leave()
            if let faculties = response.result.value,
                faculties.count > 0 {
                self.facultyPicker.source = faculties
                self.faculties = faculties
                self.facultyTextField.textField.isEnabled = true
                if !self.isFirstLoad {
                    self.facultyTextField.textField.becomeFirstResponder()
                }
                
                if self.isFirstLoad {
                    if let faculty = self.user.studentInfo?.nameFaculty {
                        for (index, value) in faculties.enumerated() {
                            if value.nameDepartment == faculty {
                                self.facultyPicker.picker.selectRow(index,
                                                                    inComponent: 0,
                                                                    animated: false)
                            }
                        }
                     }
                }
            }
        }
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
        
        levelsPicker.delegate = self
        levelEducationTextField.textField.inputAccessoryView = levelsPicker.toolBar
        levelEducationTextField.textField.inputView = levelsPicker.picker
        levelsPicker.source = levels
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
        
        if dateEndTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            dateEndTextField.errorMessage = "Поле не заполнено"
            isValid = false
        }
        
        if courseTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            courseTextField.errorMessage = "Поле не заполнено"
            isValid = false
        }
        
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
        
        return isValid
    }
    
    func setupDatePicker() {
        //Formate Date
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru")
        datePicker.backgroundColor = UIColor.white
        datePicker.maximumDate = Date()
        
        //ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = false
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

extension EditProfileViewController: SKSPickerDelegate {
    func donePicker(picker: SKSPicker, value: TypeOfSourcePicker) {
        if picker == cityPicker {
            cityTextField.text = value.title
            
            instituteTextField.textField.isEnabled = false
            facultyTextField.textField.isEnabled = false
            
            instituteTextField.textField.text = ""
            facultyTextField.textField.text = ""
            
            let uuidCity = cities[cityPicker.picker.selectedRow(inComponent: 0)].uuidCity
            self.uuidCity = uuidCity ?? ""
            getInstitutions()
        }
        
        if picker == institutePicker {
            instituteTextField.text = value.title
            
            facultyTextField.textField.isEnabled = false
            
            facultyTextField.textField.text = ""
            
            let uuidUniver = universities[institutePicker.picker.selectedRow(inComponent: 0)].uuidUniver
            self.uuidUniversity = uuidUniver
            getFaculties()
        }
        
        if picker == facultyPicker {
            facultyTextField.text = value.title
            
            let uuidFaculty = faculties[facultyPicker.picker.selectedRow(inComponent: 0)].uuidDepartment
            self.uuidFaculty = uuidFaculty
            view.endEditing(true)
        }
        
        if picker == levelsPicker {
            periodTextField.textField.isEnabled = true
            
            
            levelEducationTextField.text = value.title
            let value = levels[levelsPicker.picker.selectedRow(inComponent: 0)].value
            
            if let value = Int(value) {
                periodPicker.setupPicker(levelValue: value)
            }
            
            periodTextField.text = ""
            dateEndTextField.text = ""
            courseTextField.text = ""
            
            periodTextField.textField.becomeFirstResponder()
            
            
            view.endEditing(true)
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

extension EditProfileViewController: PeriodPickerDelegate {
    func donePicker(dateStart: String, periodPicker: PeriodPicker) {
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

extension EditProfileViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        if let image = image {
            uploadImage(image: image)
        }
    }
    
    func uploadImage(image: UIImage) {
        NetworkManager.shared.uploadImage(image: image) { [weak self] response in
            if let path = response.result.value?.urlFile {
                self?.photoImageView.image = image
                self?.photo = path
            } else {
                self?.showAlert(message: NetworkErrors.common)
            }
        }
    }
}

extension EditProfileViewController: ErrorTextFieldDelegate {
    func nextTextField(errorTextField: ErrorTextField) {
        view.endEditing(true)
    }
}

extension EditProfileViewController: UITextFieldDelegate {
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
