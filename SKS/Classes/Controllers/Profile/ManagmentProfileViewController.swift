//
//  ManagmentProfileViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 24/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class ManagmentProfileViewController: BaseViewController {
    
    private lazy var onboardingViewController: OnboardingViewController = {
        let storyboard = UIStoryboard(name: "Profile", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: "\(OnboardingViewController.self)") as! OnboardingViewController
        
        return viewController
    }()
    
    private lazy var profileViewController: ProfileViewController = {
        let storyboard = UIStoryboard(name: "Profile", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: "\(ProfileViewController.self)") as! ProfileViewController
        
        return viewController
    }()
    
    var currentController: UIViewController?
    
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
        view.addSubview(viewController.view)
        
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func remove(asChildViewController viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
}
