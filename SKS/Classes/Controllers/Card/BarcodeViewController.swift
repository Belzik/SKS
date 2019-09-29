
//
//  BarcodeViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 20/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit
import EAN13BarcodeGenerator
import Crashlytics

class BarcodeViewController: BaseViewController {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var barcodeView: UIView!
    @IBOutlet weak var infoUserView: UIView!
    @IBOutlet weak var noAuthLabel: UILabel!
    @IBOutlet weak var barcodeImage: UIImageView!
    @IBOutlet weak var noAuthBarcodeLabel: UILabel!
    @IBOutlet weak var barcodeViewGenerate: UIView!
    @IBOutlet weak var gifImage: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var universityLabel: UILabel!
    @IBOutlet weak var fioLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var widthBarcode: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraintBarcode: NSLayoutConstraint!
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeLabel.adjustsFontSizeToFitWidth = true
        
        if gifImage.image != UIImage.gifImageWithName(name: "waves") {
            let gif = UIImage.gifImageWithName(name: "waves")
            gifImage.image = gif
            gifImage.layer.cornerRadius = 16
            gifImage.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }

        
        if UIDevice.modelName == "iPhone 5s" ||
            UIDevice.modelName ==  "iPhone SE" ||
            UIDevice.modelName ==  "Simulator iPhone SE" {
//            widthBarcode.constant = 250
//            bottomConstraintBarcode.constant = 12
            let font = UIFont(name: "Montserrat-Bold", size: 14)!
            self.fioLabel.font = font
            universityLabel.numberOfLines = 1
            fioLabel.numberOfLines = 2
        }
        
        photoImageView.makeCircular()
        barcodeView.setupShadow(16,
                                shadowRadius: 12,
                                color: UIColor.black.withAlphaComponent(0.5),
                                offset: CGSize(width: 0, height: 0),
                                opacity: 0.5)
        
//        if UserData.loadSaved() != nil {
//            infoUserView.isHidden = false
//            noAuthLabel.isHidden = true
//            getInfoUser()
//        } else {
//            infoUserView.isHidden = true
//            barcodeImage.image = UIImage(named: "unavailable_barcode")
//            noAuthLabel.isHidden = false
//            noAuthBarcodeLabel.isHidden = false
//            barcodeView.isHidden = false
//        }
        
        self.setTime()
        
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(setTime), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserData.loadSaved() != nil {
            infoUserView.isHidden = false
            noAuthLabel.isHidden = true
            getInfoUser()
        } else {
            self.barcodeViewGenerate.isHidden = true
            infoUserView.isHidden = true
            barcodeImage.image = UIImage(named: "unavailable_barcode")
            noAuthLabel.isHidden = false
            noAuthBarcodeLabel.isHidden = false
            barcodeView.isHidden = false
        }
    }
    
    func getInfoUser() {
        barcodeView.isHidden = true
        
        activityIndicator.startAnimating()
        NetworkManager.shared.getInfoUser { [weak self] response in
            self?.activityIndicator.stopAnimating()
            if let user = response.result.value {
                self?.layoutViews(withUser: user)
            } else {
                self?.showAlert(message: NetworkErrors.common)
            }
        }
    }
    
    func layoutViews(withUser user: UserData) {
        if let photoPath = user.studentInfo?.photo,
            let url = URL(string: photoPath) {
            photoImageView.kf.setImage(with: url)
        }
        
        fioLabel.text = user.studentInfo?.fio
        universityLabel.text = user.studentInfo?.nameUniversity
        bottomConstraintBarcode.constant = 60
        
        self.barcodeViewGenerate.isHidden = true
        if let status = user.status {
            switch status {
            case ProfileStatus.active.rawValue:
                statusLabel.text = "Аккаунт подтвержден"
                statusLabel.textColor = ColorManager.green.value
                noAuthBarcodeLabel.isHidden = true
                
                if let codeStudent = user.studentCode {
                    if UIDevice.modelName == "iPhone 5s" ||
                        UIDevice.modelName ==  "iPhone SE" ||
                        UIDevice.modelName ==  "Simulator iPhone SE" {
                        widthBarcode.constant = 250
                        bottomConstraintBarcode.constant = 12
                        let font = UIFont(name: "Montserrat-Bold", size: 14)!
                        self.fioLabel.font = font
                        
                        let rect = CGRect(x: 0, y: 0, width: 250, height: 100)
                        let barcodeView = BarCodeView(frame: rect)
                        barcodeView.barCode = codeStudent
                        self.barcodeViewGenerate.addSubview(barcodeView)
                        self.barcodeViewGenerate.isHidden = false
                    } else {
                        let rect = CGRect(x: 0, y: 0, width: 300, height: 100)
                        let barcodeView = BarCodeView(frame: rect)
                        barcodeView.barCode = codeStudent
                        self.barcodeViewGenerate.addSubview(barcodeView)
                        self.barcodeViewGenerate.isHidden = false
                    }
                }
            case ProfileStatus.blocked.rawValue:
                statusLabel.text = "Аккаунт заблокирован"
                statusLabel.textColor = ColorManager.red.value
                barcodeImage.image = UIImage(named: "unavailable_barcode")
                noAuthBarcodeLabel.isHidden = false
            case ProfileStatus.moderation.rawValue:
                statusLabel.text = "Ждем в профкоме"
                statusLabel.textColor = ColorManager.yellow.value
                barcodeImage.image = UIImage(named: "unavailable_barcode")
                noAuthBarcodeLabel.isHidden = false
            case ProfileStatus.rejected.rawValue:
                statusLabel.text = "Ошибка"
                statusLabel.textColor = ColorManager.red.value
                barcodeImage.image = UIImage(named: "unavailable_barcode")
                noAuthBarcodeLabel.isHidden = false
            default:
                statusLabel.isHidden = true
            }
        }
        
        if UIDevice.modelName == "iPhone 5s" ||
            UIDevice.modelName ==  "iPhone SE" {
            
        }
        
        UIView.transition(with: barcodeView,
                          duration: 0.3,
                          options: .transitionCrossDissolve, animations: { [weak self] in
                            self?.barcodeView.isHidden = false
            }, completion: nil)
    }
    
    @objc func setTime(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .medium
        let locale = Locale.init(identifier: "ru")
        dateFormatter.locale = locale
        let date = Date()
        let time = dateFormatter.string(from: date)
        timeLabel.text = time
    }
}
