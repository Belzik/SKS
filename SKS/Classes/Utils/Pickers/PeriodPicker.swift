//
//  PeriodsPicker.swift
//  SKS
//
//  Created by Александр Катрыч on 27/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

protocol PeriodPickerDelegate: class {
    func donePicker(dateStart: String, periodPicker: PeriodPicker)
    func cancelPicker()
}

class PeriodPicker: NSObject {
    var toolBar = UIToolbar()
    var picker = UIPickerView()
    var dateStart: [String] = []
    var dateEnd: [String] = []
    
    weak var delegate: PeriodPickerDelegate?
    
    override init() {
        super.init()
        
        var dateEnd: [String] = []
        var dateStart: [String] = []
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        
        self.dateEnd.append("до")
        for item in (year...year+10).reversed() {
            dateEnd.append(String(describing: item))
        }
        
        for item in (year-10...year).reversed() {
            dateStart.append(String(describing: item))
        }
        
        self.dateEnd += dateEnd
        self.dateStart += dateStart
    
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
        let dateSt = dateStart[picker.selectedRow(inComponent: 0)]
        //var dateE = dateEnd[picker.selectedRow(inComponent: 1)]
        
//        if dateSt == "c" {
//            dateSt = dateStart[1]
//        }
//
//        if dateE == "до" {
//            if let last = dateEnd.last {
//                dateE = last
//            }
//        }
        
        delegate?.donePicker(dateStart: dateSt, periodPicker: self)
    }
    
    @objc private func cancelPicker() {
        delegate?.cancelPicker()
    }
    
    func setupPicker(levelValue: Int, isInverted: Bool = false) {
        if isInverted {
            let date = Date()
            let calendar = Calendar.current
            let year = calendar.component(.year, from: date)
            
            dateStart = []
            
            for value in year...(year + levelValue + 1) {
                dateStart.append(String(describing: value))
            }
            
            picker.reloadComponent(0)
        } else {
            let date = Date()
            let calendar = Calendar.current
            let year = calendar.component(.year, from: date)
            
            dateStart = []
            
            for value in (year - levelValue + 1)...year {
                dateStart.append(String(describing: value))
            }
            picker.reloadComponent(0)
        }
    }
}

extension PeriodPicker: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dateStart.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dateStart[row]
    }
}
