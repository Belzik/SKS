//
//  Picker.swift
//  SKS
//
//  Created by Александр Катрыч on 26/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

protocol SKSPickerDelegate: class {
    func donePicker(picker: SKSPicker, value: TypeOfSourcePicker)
    func cancelPicker()
}

protocol TypeOfSourcePicker: class {
    var title: String { get }
}

class SKSPicker: NSObject {
    var toolBar = UIToolbar()
    var picker = UIPickerView()
    var source: [TypeOfSourcePicker] = []
    weak var delegate: SKSPickerDelegate?
    
    override init() {
        super.init()
        
        picker.backgroundColor = UIColor.white
        picker.delegate = self
        picker.dataSource = self
        
        toolBar.barStyle = .default
        toolBar.isTranslucent = false
        toolBar.tintColor = ColorManager.lightBlack.value
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Готово",
                                         style: .done,
                                         target: self,
                                         action: #selector(donePicker))
        doneButton.tintColor = ColorManager.green.value
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                          target: nil,
                                          action: nil)
        let cancelButton = UIBarButtonItem(title: "Отмена",
                                           style: .plain,
                                           target: self,
                                           action: #selector(cancelPicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
    }
    
    @objc private func donePicker() {
        let value = source[picker.selectedRow(inComponent: 0)]
        delegate?.donePicker(picker: self, value: value)
    }
    
    @objc private func cancelPicker() {
        delegate?.cancelPicker()
    }
}

extension SKSPicker: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return source.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return source[row].title
    }
}
