//
//  ComplaintViewController.swift
//  SKS
//
//  Created by Alexander on 06/12/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class ComplaintViewController: BaseViewController {
    @IBOutlet weak var firstCheckbox: Checkbox!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondCheckbox: Checkbox!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdCheckbox: Checkbox!
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var complaintTextField: SKSTextField!
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendButtonTapped(_ sender: SKSButton) {
        sendComplaint()
    }
    
    var uuidPartner: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabeles()
        complaintTextField.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func setupLabeles() {
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(firstLabelTapped))
        firstLabel.isUserInteractionEnabled = true
        firstLabel.addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(secondLabelTapped))
        secondLabel.isUserInteractionEnabled = true
        secondLabel.addGestureRecognizer(tap2)
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(thirdLabelTapped))
        thirdLabel.isUserInteractionEnabled = true
        thirdLabel.addGestureRecognizer(tap3)
        
    }
    
    @objc func firstLabelTapped() {
        firstCheckbox.button.isSelected = !firstCheckbox.button.isSelected
    }
    
    @objc func secondLabelTapped() {
        secondCheckbox.button.isSelected = !secondCheckbox.button.isSelected
    }
    
    @objc func thirdLabelTapped() {
        thirdCheckbox.button.isSelected = !thirdCheckbox.button.isSelected
    }
    
    func sendComplaint() {
        var complaint = ""
        
        if firstCheckbox.isSelected {
            complaint = "Не приняли карту / не сделали скидку"
        }
        
        if secondCheckbox.isSelected {
            if complaint != "" { complaint += "\n "}
            complaint += "Некорретная информация о размере скидки / акции"
        }
        
        if thirdCheckbox.isSelected {
            if complaint != "" { complaint += "\n "}
            complaint += "Плохое обслуживание"
        }
        
        if let text = complaintTextField.text,
            text != "" {
            if complaint != "" { complaint += "\n "}
            complaint += text
        }
        
        NetworkManager.shared.sendComplaintToPartner(uuidPartner: uuidPartner,
                                                     complaint: complaint) { [weak self] result in
            if result.statusCode == 200 {
                let alertAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                    self?.dismiss(animated: true, completion: nil)
                }
                self?.showAlert(actions: [alertAction], title: "Успех", message: "Ваша жалоба отправлена")
            } else {
                self?.showAlert(message: NetworkErrors.common)
            }
        }
    }
}

extension ComplaintViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        
        return true
    }
}
