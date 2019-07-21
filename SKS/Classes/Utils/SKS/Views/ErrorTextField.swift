//
//  SKSTextFIeld.swift
//  SKS
//
//  Created by Александр Катрыч on 15/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import SkyFloatingLabelTextField
import UIKit

protocol ErrorTextFieldDelegate: class {
    func nextTextField(errorTextField: ErrorTextField)
}

class ErrorTextField: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var textField: SKSTextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    private var typeOfButton: TypeOfButton = .shadowAndBackground
    
    @IBInspectable var text: String? {
        get {
            return self.textField.text
        }
        set(string) {
            self.textField.text = string
        }
    }
    
    @IBInspectable var placeholder: String? {
        get {
            return self.textField.placeholder
        }
        set(string) {
            self.textField.placeholder = string
        }
    }
    
    var errorMessage: String = "" {
        didSet {
            errorLabel.text = errorMessage
            
            if errorMessage == "" {
                textField.selectedLineColor = ColorManager.green.value
                textField.lineColor = UIColor.gray
            } else {
                textField.selectedLineColor = ColorManager.red.value
                textField.lineColor = ColorManager.red.value
            }
        }
    }
    
    weak var delegate: ErrorTextFieldDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("\(ErrorTextField.self)", owner: self, options: nil)
        
        textField.tintColor = UIColor.gray
        textField.selectedLineColor = ColorManager.green.value
        textField.selectedTitleColor = UIColor.gray
        textField.lineHeight = 1
        textField.selectedLineHeight = 1
        textField.titleFont = UIFont.systemFont(ofSize: 12)
        textField.titleFormatter = { string in
            return string
        }

        textField.titleLabel.adjustsFontSizeToFitWidth = true
        
        contentView.frame = self.bounds
        addSubview(contentView)
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        textField.delegate = self
    }
}

extension ErrorTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setupError(forTextField: textField as! SKSTextField)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        //let isDeleted = newString.count < textField.text!.count

        textField.text = newString
        setupError(forTextField: textField as! SKSTextField)
        return false
    }

    private func setupError(forTextField textField: SKSTextField) {
        if textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            textField.selectedLineColor = ColorManager.green.value
            textField.lineColor = UIColor.gray
            errorMessage = ""
        }

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.nextTextField(errorTextField: self)
        
        return true
    }
}
