//
//  MenuTabsView.swift
//  SKS
//
//  Created by Александр Катрыч on 08/11/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class MenuTabsView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //var menuDelegate: MenuBarDelegate?
    var cellId = "BasicCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        customInitializer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        customInitializer()
    }
    
    func customInitializer() {
        collectionView.register(BasicCell.self, forCellWithReuseIdentifier: cellId)
        
        addSubview(collectionView)
        addConstraintWithFormatString(formate: "V:|[v0]|", views: collectionView)
        addConstraintWithFormatString(formate: "H:|[v0]|", views: collectionView)
        backgroundColor = .clear
    }

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()

    var isSizeToSitCellsNeeded: Bool = false {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    var dataArray: [String] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? BasicCell {
            cell.titleLabel.text = dataArray[indexPath.item]
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isSizeToSitCellsNeeded {
            let size = CGSize.init(width: 500, height: self.frame.height)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            
            let str = dataArray[indexPath.item]
            
            let estimatedRect = NSString.init(string: str).boundingRect(with: size,
                                                                        options: options,
                                                                        attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 23)],
                                                                        context: nil)
            
            return CGSize.init(width: estimatedRect.size.width,
                               height: self.frame.height)
        }
        
        return CGSize.init(width: (self.frame.width - 10)/CGFloat(dataArray.count),
                           height: self.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let index = Int(indexPath.item)
        
        //menuDelegate?.menuBarDidSelectItemAt(menu: self, index: index)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0,
                            left: 5,
                            bottom: 0,
                            right: 5)
    }
}
