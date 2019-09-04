//
//  PeriodsPicker.swift
//  SKS
//
//  Created by Александр Катрыч on 27/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

protocol PeriodPickerDelegate: class {
    func donePicker(dateStart: String, dateEnd: String)
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
        self.dateStart.append("c")
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
        var dateSt = dateStart[picker.selectedRow(inComponent: 0)]
        var dateE = dateEnd[picker.selectedRow(inComponent: 1)]
        
        if dateSt == "c" {
            dateSt = dateStart[1]
        }
        
        if dateE == "до" {
            if let last = dateEnd.last {
                dateE = last
            }
        }
        
        delegate?.donePicker(dateStart: dateSt, dateEnd: dateE)
    }
    
    @objc private func cancelPicker() {
        delegate?.cancelPicker()
    }
}

extension PeriodPicker: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return dateStart.count
        } else {
            return dateEnd.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return dateStart[row]
        } else {
            return dateEnd[row]
        }
    }
}
