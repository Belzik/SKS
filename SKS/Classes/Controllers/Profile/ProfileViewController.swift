//
//  ProfileViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 24/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

protocol ProfileDelegate: class {
    func exit()
    func editProfile(userData: UserData)
}

enum ProfileStatus: String {
    case active = "active"
    case newuser = "newuser"
    case clearuser = "clearuser"
    case blocked = "blocked"
    case moderation = "moderation"
    case rejected = "rejected"
}

class ProfileViewController: BaseViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var fioLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var universityLabel: UILabel!
    @IBOutlet weak var facultyLabel: UILabel!
    @IBOutlet weak var specialityLabel: UILabel!
    @IBOutlet weak var speacialityStackView: UIStackView!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var sheverevImage: UIImageView!
    @IBOutlet weak var sheverevLabel: UILabel!
    
    
    weak var delegate: ProfileDelegate?
    var user: UserData?
    
    @IBAction func exitButton(_ sender: UIButton) {
        UserData.clear()
        delegate?.exit()
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        guard let user = self.user else { return }
        delegate?.editProfile(userData: user)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.modelName == "iPhone 5s" ||
            UIDevice.modelName ==  "iPhone SE" ||
            UIDevice.modelName ==  "Simulator iPhone SE" {
            let font = UIFont(name: "Montserrat-Bold", size: 20)!
            self.fioLabel.font = font
            
        }
        setupSheverev()
        
        profileImage.makeCircular()
        profileImage.layer.masksToBounds = true
        profileImage.layer.borderColor = UIColor.white.cgColor
        profileImage.layer.borderWidth = 2.0
    }
    
    func setupSheverev() {
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(sheverevTapped))
        sheverevImage.isUserInteractionEnabled = true
        sheverevImage.addGestureRecognizer(tapImage)
        
        let tapLabel = UITapGestureRecognizer(target: self, action: #selector(sheverevTapped))
        sheverevLabel.isUserInteractionEnabled = true
        sheverevLabel.addGestureRecognizer(tapLabel)
    }
    
    @objc func sheverevTapped() {
        if let url = URL(string: "http://www.sheverev.com"), UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func getInfoUser() {
        contentView.isHidden = true
        activityIndicator.startAnimating()
        NetworkManager.shared.getInfoUser { [weak self] response in
            self?.activityIndicator.stopAnimating()
            if let user = response.value {
                self?.user = user
                self?.layoutViews(withUser: user)
            } else {
                self?.showAlert(message: NetworkErrors.common)
            }
        }
    }
    
    func layoutViews(withUser user: UserData) {
        if let photoPath = user.studentInfo?.photo,
            let url = URL(string: photoPath) {
            profileImage.kf.setImage(with: url) { (image, _) in
//                if image == nil {
//                    self?.profileImage.image = UIImage(named: "ic_photo")
//                }
            }
        }
        
        fioLabel.text = user.studentInfo?.fio
        birthdayLabel.text = user.studentInfo?.birthdate
        cityLabel.text = user.studentInfo?.nameCity
        universityLabel.text = user.studentInfo?.nameUniversity
        facultyLabel.text = user.studentInfo?.nameFaculty
        
        
        if let nameSpecialty = user.studentInfo?.nameSpecialty,
            nameSpecialty != "" {
            specialityLabel.text = nameSpecialty
        } else {
            speacialityStackView.isHidden = true
        }
        
        
        if let startEdu = user.studentInfo?.startEducation,
            let endEdu = user.studentInfo?.endEducation {
            periodLabel.text = "\(startEdu) - \(endEdu)"
        }
        
        if let course = user.studentInfo?.course { courseLabel.text = String(describing: course) }
        if let phone = user.phone { phoneLabel.text = phone.with(mask: "* *** *** ** **", replacementChar: "*", isDecimalDigits: true) }
        
        editButton.isHidden = true
        if let status = user.status {
            
            switch status {
            case ProfileStatus.active.rawValue:
                statusLabel.text = "Аккаунт подтвержден"
                statusLabel.textColor = ColorManager.green.value
                reasonLabel.isHidden = true
            case ProfileStatus.blocked.rawValue:
                statusLabel.text = "Аккаунт заблокирован"
                statusLabel.textColor = ColorManager.red.value
                reasonLabel.text = user.statusReason
                reasonLabel.isHidden = false
            case ProfileStatus.moderation.rawValue:
                statusLabel.text = "Для завершения регистрации загляни в Профком"
                statusLabel.textColor = ColorManager.yellow.value
                reasonLabel.isHidden = true
            case ProfileStatus.rejected.rawValue:
                statusLabel.text = "Ошибка"
                statusLabel.textColor = ColorManager.red.value
                reasonLabel.text = user.statusReason
                reasonLabel.isHidden = false
                editButton.isHidden = false
            default:
                statusLabel.isHidden = true
                reasonLabel.isHidden = true
            }
        }
        
        UIView.transition(with: contentView,
                          duration: 0.3,
                          options: .transitionCrossDissolve, animations: { [weak self] in
                            self?.contentView.isHidden = false
        }, completion: nil)
        
    }
}
