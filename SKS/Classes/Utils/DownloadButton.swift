//
//  DownloadButton.swift
//  Autonomy
//
//  Created by Alexander on 26/07/2019.
//  Copyright © 2019 Elvas. All rights reserved.
//

import UIKit

class DownloadButton: SKSButton {
    
    // MARK: - Properties
    
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .white)
    var savedTitle = ""
    
    var isDownload: Bool = false {
        didSet {
            isEnabled = !isDownload
            isDownload ? setTitle("", for: .normal) : setTitle(savedTitle, for: .normal)
            isDownload ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        }
    }
    
    // MARK: - Object life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func commonInit() {
        savedTitle = title(for: .normal) ?? ""
        activityIndicator.hidesWhenStopped = true
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    // MARK: - Methods
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        
        if !isDownload {
            savedTitle = title ?? ""
        }
    }
    
}
