//
//  HomeViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 21/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class HomeViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var cityView: UIView!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var cityLabel: UILabel!
    
    var selectedIndex: Int = -1
    var sections: [String] = [""]
    let sectionsBuffer: [String] = ["", "Акции", "Партнеры"]
    
    var categories: [Category] = []
    var stocks: [Stock] = []
    var partners: [Partner] = []
    
    var picker: SKSPicker = SKSPicker()
    var cities: [City] = []
    
    let dispatchGroup = DispatchGroup()
    
    var currentCity: City?
    var searchString: String?
    var currentUiidCategory: String?
    var isCityTextFieldEditing = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem(title: "Назад", style: .plain, target: nil, action: nil)
        backButton.tintColor = UIColor(hexString: "#333333")
        navigationItem.backBarButtonItem = backButton
        
        getCities()
        //loadData()
        setupTableView()
        setupCityView()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueStock",
            let uuidStock = sender as? String {
            let dvc = segue.destination as! StockViewController
            dvc.uuid = uuidStock
            dvc.city = currentCity
        }
        
        if segue.identifier == "seguePartner",
            let uuidStock = sender as? String {
            let dvc = segue.destination as! PartnerViewController
            dvc.uuidPartner = uuidStock
            dvc.city = currentCity
        }
    }
    
    private func setupCityView() {
        picker.delegate = self
        
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(cityViewTapped))
        cityView.isUserInteractionEnabled = true
        cityView.addGestureRecognizer(tap)
        
        cityTextField.inputAccessoryView = picker.toolBar
        cityTextField.inputView = picker.picker
    }
    
    @objc func cityViewTapped() {
        if isCityTextFieldEditing {
            view.endEditing(true)
            isCityTextFieldEditing = false
        } else {
            cityTextField.becomeFirstResponder()
            isCityTextFieldEditing = true
        }
    }
    
    private func getCities() {
        activityIndicator.startAnimating()
        NetworkManager.shared.getCityPartners { [weak self] response in
            if let cities = response.result.value {
                self?.cities = cities
                self?.picker.source = cities
                
                for city in cities {
                    if city.nameCity == "Петрозаводск" {
                        self?.currentCity = city
                        self?.cityLabel.text = city.nameCity
                    }
                }
                
                if self?.cityLabel.text == "Город" {
                    self?.currentCity = cities.first
                    self?.cityLabel.text = cities.first?.nameCity
                }
                
                self?.loadData()
            } else {
                self?.showAlert(message: NetworkErrors.common)
                self?.activityIndicator.stopAnimating()
            }
        }
    }
    
    private func loadData() {
        sections = [""]
        
        if categories.count == 0 { getCategories() }
        getPartners()
        getStocks()
        
        dispatchGroup.notify(queue: .main) { [unowned self] in
            self.activityIndicator.stopAnimating()
            self.tableView.reloadData()
            
            if self.stocks.count > 0 {
                self.sections.append("Акции")
            }
            
            if self.partners.count > 0 {
                self.sections.append("Партнеры")
            }
            
            if self.tableView.isHidden {
                self.tableView.reloadData()
                self.tableView.isHidden = false
                self.cityView.isHidden = false
            } else {
                UIView.transition(with: self.tableView,
                                  duration: 0.2,
                                  options: .transitionCrossDissolve, animations: {
                    self.tableView.reloadData()
                }, completion: nil)
            }
        }
    }
    
    private func getCategories() {
        dispatchGroup.enter()
        NetworkManager.shared.getCategories { [weak self] response in
            self?.dispatchGroup.leave()
            if let categories = response.result.value {
                self?.categories = categories
            }
            
            if let error = response.result.error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func getPartners() {
        dispatchGroup.enter()
        NetworkManager.shared.getPartners(category: currentUiidCategory,
                                          uuidCity: currentCity?.uuidCity) { [weak self] response in
            self?.dispatchGroup.leave()
            if let partners = response.result.value {
                self?.partners = partners
            }
            
            if let error = response.result.error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func getStocks() {
        dispatchGroup.enter()
        NetworkManager.shared.getStocks(category: currentUiidCategory,
                                        uuidCity: currentCity?.uuidCity) { [weak self] response in
            self?.dispatchGroup.leave()
            if let stocks = response.result.value {
                self?.stocks = stocks
            }
            
            if let error = response.result.error {
                print(error.localizedDescription)
            }
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)

        tableView.register(UINib(nibName: "\(PartnerTableViewCell.self)",
                                 bundle: nil),
                           forCellReuseIdentifier: "\(PartnerTableViewCell.self)")

        tableView.register(UINib(nibName: "\(CategoryTableViewCell.self)",
                                 bundle: nil),
                           forCellReuseIdentifier: "\(CategoryTableViewCell.self)")

        tableView.register(UINib(nibName: "\(StockTableViewCell.self)",
            bundle: nil),
                           forCellReuseIdentifier: "\(StockTableViewCell.self)")
        
        tableView.register(UINib(nibName: "\(TitleTableViewHeader.self)",
                                 bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "\(TitleTableViewHeader.self)")

        // Для того, чтобы не плавал header
        let dummyViewHeight = CGFloat(40)
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyViewHeight))
        self.tableView.contentInset = UIEdgeInsets(top: -dummyViewHeight, left: 0, bottom: 0, right: 0)
        
        //tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        if section == 1 {
            if stocks.count == 0 {
                return partners.count
            } else {
                return 1
            }
        }
        return partners.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(CategoryTableViewCell.self)",
                                                     for: indexPath) as! CategoryTableViewCell

            cell.setCollectionViewDataSourceDelegate(self)
            cell.collectionView.tag = 1

            return cell
        } else if indexPath.section == 1 && stocks.count != 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(StockTableViewCell.self)",
                for: indexPath) as! StockTableViewCell

            cell.setCollectionViewDataSourceDelegate(self)
            cell.collectionView.tag = 2

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(PartnerTableViewCell.self)",
                for: indexPath) as! PartnerTableViewCell

            cell.model = partners[indexPath.row]

            return cell
        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 2 ||
            stocks.count == 0 {
            if let uuidPartner = partners[indexPath.row].uuidPartner {
                performSegue(withIdentifier: "seguePartner", sender: uuidPartner)
            }
            
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 0 {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "\(TitleTableViewHeader.self)") as! TitleTableViewHeader
            header.nameLabel.text = sections[section]
            header.contentView.backgroundColor = .white
            
            
            return header
        }

        return nil
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 40
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1 {
            return categories.count
        } else {
            return stocks.count
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(CategoryCollectionViewCell.self)",
                for: indexPath) as! CategoryCollectionViewCell

            if indexPath.row == 0 {
                cell.leftConstraintMainView.constant = 16
            } else {
                cell.leftConstraintMainView.constant = 4
            }

            if indexPath.row == categories.count - 1 {
                cell.rightConstraintMainView.constant = 16
            } else {
                cell.rightConstraintMainView.constant = 4
            }

            cell.model = categories[indexPath.row]

            return cell
        }

        if collectionView.tag == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(StockCollectionViewCell.self)",
                for: indexPath) as! StockCollectionViewCell

            if indexPath.row == 0 {
                cell.leftConstraintMainView.constant = 16
            } else {
                cell.leftConstraintMainView.constant = 4
            }

            if indexPath.row == stocks.count - 1 {
                cell.rightConstraintMainView.constant = 16
            } else {
                cell.rightConstraintMainView.constant = 4
            }
            
            cell.model = stocks[indexPath.row]

            return cell
        }

        let cell = UICollectionViewCell()
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 2 {
            return CGSize(width: view.bounds.width - 12, height: 160)
        }
        
        if indexPath.row == 0 ||
            indexPath.row == categories.count - 1 {
            return CGSize(width: 120, height: 124)
        } else {
            return CGSize(width: 108, height: 124)
        }

    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1 {
            if selectedIndex == -1 {
                categories[indexPath.row].isSelected = true
                selectedIndex = indexPath.row
                
                if let uuid = categories[indexPath.row].uuidCategory { currentUiidCategory = uuid }
                
                changeBackgroundColorCell(collectionView, indexPath: indexPath)
                loadData()

            } else if selectedIndex == indexPath.row {
                categories[indexPath.row].isSelected = false
                currentUiidCategory = nil
                selectedIndex = -1
                
                changeBackgroundColorCell(collectionView, indexPath: indexPath)
                loadData()
            } else {
                categories[selectedIndex].isSelected = false
                categories[indexPath.row].isSelected = true
                if let uuid = categories[indexPath.row].uuidCategory { currentUiidCategory = uuid }
                
                changeBackgroundColorCell(collectionView, indexPath: IndexPath(row: selectedIndex, section: 0))
                changeBackgroundColorCell(collectionView, indexPath: indexPath)
                
                loadData()
                selectedIndex = indexPath.row
            }
        }
        
        if collectionView.tag == 2 {
            if let uuidStock = stocks[indexPath.row].uuidStock {
                performSegue(withIdentifier: "segueStock", sender: uuidStock)
            }
        }
    }
    
    func changeBackgroundColorCell(_ collectionView: UICollectionView, indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell {
            let model = categories[indexPath.row]
            
            UIView.animate(withDuration: 0.2) {
                if model.isSelected {
                    cell.titleLabel.textColor = .white
                    cell.colorView.backgroundColor = UIColor(hexString: "\(model.hexcolor!)")
                    
                    let newImage = cell.iconImageView.image?.withRenderingMode(.alwaysTemplate)
                    cell.iconImageView.tintColor = .white
                    cell.iconImageView.image = newImage
                } else {
                    cell.colorView.backgroundColor = .white
                    cell.titleLabel.textColor = ColorManager.lightBlack.value
                    
                    let newImage = cell.iconImageView.image?.withRenderingMode(.alwaysTemplate)
                    cell.iconImageView.image = newImage
                    cell.iconImageView.tintColor = ColorManager.lightBlack.value
                }
            }
        }
    }
}

extension HomeViewController: SKSPickerDelegate {    
    func donePicker(picker: SKSPicker, value: TypeOfSourcePicker) {
        if value.title == currentCity?.nameCity {
            view.endEditing(true)
            return
        }
        
        cityLabel.text = value.title
        for city in cities {
            if city.nameCity == value.title {
                currentCity = city
                break
            }
        }
        loadData()
        //currentCity
        
        view.endEditing(true)
    }
    
    func cancelPicker() {
        view.endEditing(true)
    }
}
