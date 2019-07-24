//
//  CategoryTableViewCell.swift
//  SKS
//
//  Created by Александр Катрыч on 23/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCollectionViewDataSourceDelegate(_ dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate) {
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 24, right: 0)
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.setNeedsLayout()
        collectionView.layoutIfNeeded()
        
        collectionView.register(UINib(nibName: "\(CategoryCollectionViewCell.self)",
                                 bundle: nil),
                                forCellWithReuseIdentifier: "\(CategoryCollectionViewCell.self)")
        
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.reloadData()
    }
}
