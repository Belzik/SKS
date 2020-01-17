//
//  CategoriesViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 16/11/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit


class CategoriesViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var categories: [Category] = []
    var selectedIndexPath: IndexPath?
    var uuidCategory = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        getCategories()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    private func getCategories() {
        tableView.isHidden = true
        activityIndicatorView.startAnimating()
        
        NetworkManager.shared.getCategories { [weak self] response in
            self?.activityIndicatorView.stopAnimating()
            if let categories = response.result.value {
                for (index, category) in categories.enumerated() {
                    if let uuidCategory = self?.uuidCategory,
                        let uuid = category.uuidCategory,
                        uuidCategory == uuid {
                        category.isSelected = true
                        self?.selectedIndexPath = IndexPath(row: index, section: 0)
                    }
                }
                
                self?.categories = categories
                self?.tableView.reloadData()
                self?.tableView.isHidden = false
            } else {
                self?.showAlert(message: NetworkErrors.common)
            }
        }
    }
}

extension CategoriesViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.register(UINib(nibName: "\(CategoryFilterTableViewCell.self)", bundle: nil),
                           forCellReuseIdentifier: "\(CategoryFilterTableViewCell.self)")
        
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        tableView.contentInset = UIEdgeInsets.init(top: 12, left: 0, bottom: 0, right: 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(CategoryFilterTableViewCell.self)",
                                                 for: indexPath) as! CategoryFilterTableViewCell
        
        cell.delegate = self
        cell.indexPath = indexPath
        cell.model = categories[indexPath.row]
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedIndexPath = self.selectedIndexPath {
            if selectedIndexPath == indexPath {
                categories[indexPath.row].isSelected = false
                
                tableView.reloadRows(at: [indexPath], with: .automatic)
                
                self.selectedIndexPath = nil
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeCategory"),
                                                object: nil,
                                                userInfo: ["uuidCategory": ""])
            } else {
                categories[indexPath.row].isSelected = true
                categories[selectedIndexPath.row].isSelected = false
                
                tableView.reloadRows(at: [indexPath, selectedIndexPath], with: .automatic)
                
                self.selectedIndexPath = indexPath
                
                if let uuidCategory = categories[indexPath.row].uuidCategory {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeCategory"),
                                                    object: nil,
                                                    userInfo: ["uuidCategory": uuidCategory])
                }
            }
        } else {
            categories[indexPath.row].isSelected = true
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
            selectedIndexPath = indexPath
            
            if let uuidCategory = categories[indexPath.row].uuidCategory {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeCategory"),
                                                object: nil,
                                                userInfo: ["uuidCategory": uuidCategory])
            }
        }
    }
}

extension CategoriesViewController: CategoryFilterTableViewCellDelegate {
    func checkboxTapped(indexPath: IndexPath) {
        if let selectedIndexPath = self.selectedIndexPath {
            if selectedIndexPath == indexPath {
                categories[indexPath.row].isSelected = false
                
                tableView.reloadRows(at: [indexPath], with: .automatic)
                
                self.selectedIndexPath = nil
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeCategory"),
                                                object: nil,
                                                userInfo: ["uuidCategory": ""])
            } else {
                categories[indexPath.row].isSelected = true
                categories[selectedIndexPath.row].isSelected = false
                
                tableView.reloadRows(at: [indexPath, selectedIndexPath], with: .automatic)
                
                self.selectedIndexPath = indexPath
                
                if let uuidCategory = categories[indexPath.row].uuidCategory {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeCategory"),
                                                    object: nil,
                                                    userInfo: ["uuidCategory": uuidCategory])
                }
            }

        } else {
            categories[indexPath.row].isSelected = true
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
            selectedIndexPath = indexPath
            
            if let uuidCategory = categories[indexPath.row].uuidCategory {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeCategory"),
                                                object: nil,
                                                userInfo: ["uuidCategory": uuidCategory])
            }
        }
    }
}
