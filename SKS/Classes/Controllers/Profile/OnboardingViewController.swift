//
//  OnboardingViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 24/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

struct PageSource {
    var text: String
    var image: UIImage?
}

protocol OnboardingViewControllerDelegate: class {
    func showLogin()
}

class OnboardingViewController:  BaseViewController {
    @IBOutlet weak var contentView: UIView!
    
    let dataSource = [
        PageSource(text: "Узнавайте про самые выгодные предложения первыми",
                   image: UIImage(named: "horn")),
        PageSource(text: "Используйте дисконтную карту прямо с экрана",
                   image: UIImage(named: "phone")),
        PageSource(text: "Пользуйтесь приложением по всей России",
                   image: UIImage(named: "map"))
    ]
    
    weak var delegate: OnboardingViewControllerDelegate?
    
    var currentViewControllerIndex = 0
    
    @IBAction func enterButtonTapped(_ sender: UIButton) {
        delegate?.showLogin()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePageViewController()
        
        
    }
    
    func configurePageViewController() {
        guard let pageViewController = storyboard?.instantiateViewController(withIdentifier: "\(OnboardingPageViewController.self)") as? OnboardingPageViewController else { return }
        
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        
        
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(pageViewController.view)
        
        let views: [String: Any] = ["pageView": pageViewController.view as Any]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[pageView]-0-|",
                                                                 options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                                 metrics: nil,
                                                                 views: views))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[pageView]-0-|",
                                                                 options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                                 metrics: nil,
                                                                 views: views))
        
        guard let startingViewController = detailViewControllerAt(index: currentViewControllerIndex) else { return }
        
        pageViewController.setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
    }
    
    func detailViewControllerAt(index: Int) -> OnboardingDataViewController? {
        if index >= dataSource.count || dataSource.count == 0 {
            return nil
        }
        
        guard let dataViewController = storyboard?.instantiateViewController(withIdentifier: "\(OnboardingDataViewController.self)") as? OnboardingDataViewController else { return nil }
        
        dataViewController.index = index
        dataViewController.pageSource = dataSource[index]
        
        return dataViewController
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentViewControllerIndex
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return dataSource.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let dataViewContoller = viewController as? OnboardingDataViewController
        
        guard var currentIndex = dataViewContoller?.index else { return nil }
        
        if currentIndex == 0 { return nil }
        
        currentIndex -= 1
        currentViewControllerIndex = currentIndex
        
        return detailViewControllerAt(index: currentIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let dataViewContoller = viewController as? OnboardingDataViewController
        
        guard var currentIndex = dataViewContoller?.index else { return nil }
        
        if currentIndex == dataSource.count { return nil }
        
        currentIndex += 1
        currentViewControllerIndex = currentIndex
        
        return detailViewControllerAt(index: currentIndex)
    }
}
