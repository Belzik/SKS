//
//  ManagmentProfileViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 24/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class ManagmentProfileViewController: BaseViewController {
    @IBOutlet weak var contentView: UIView!
    private lazy var onboardingViewController: OnboardingViewController = {
        let storyboard = UIStoryboard(name: "Profile", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: "\(OnboardingViewController.self)") as! OnboardingViewController
        viewController.delegate = self
        
        return viewController
    }()
    
    private lazy var profileViewController: ProfileViewController = {
        let storyboard = UIStoryboard(name: "Profile", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: "\(ProfileViewController.self)") as! ProfileViewController
        viewController.delegate = self
        
        return viewController
    }()
    
    var currentController: UIViewController?
    var userData: UserData?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if UserData.loadSaved() != nil {
            return .lightContent
        } else {
            return .default
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueEditProfile" {
            let dvc = segue.destination as! EditProfileViewController
            dvc.user = userData
        }
    }
    
    func reload() {
        if let vc = currentController {
            remove(asChildViewController: vc)
        }
        
        if UserData.loadSaved() != nil {
            currentController = profileViewController
            add(asChildViewController: profileViewController)
            profileViewController.getInfoUser()
        } else {
            currentController = onboardingViewController
            add(asChildViewController: onboardingViewController)
        }
    }

    func add(asChildViewController viewController: UIViewController) {
        contentView.addSubview(viewController.view)
        viewController.view.frame = contentView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func remove(asChildViewController viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
}

extension ManagmentProfileViewController: ProfileDelegate {
    func exit() {
        //reload()
        if let vc = UIStoryboard(name: "Home", bundle: nil).instantiateInitialViewController() {
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func editProfile(userData: UserData) {
        self.userData = userData
        performSegue(withIdentifier: "segueEditProfile", sender: nil)
    }
}

extension ManagmentProfileViewController: OnboardingViewControllerDelegate {
    func showLogin() {
        if let vc = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController() {
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
}
