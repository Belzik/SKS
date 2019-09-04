 //
//  PageViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 27/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

 class OnboardingPageViewController: UIPageViewController {
    var pageControl: UIPageControl? {
        for subview in view.subviews {
            if let pageControl = subview as? UIPageControl {
                return pageControl
            }
        }
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl?.pageIndicatorTintColor = UIColor(hexString: "#383C45")
        pageControl?.currentPageIndicatorTintColor = UIColor(hexString: "#1AAB58")
    }

}
