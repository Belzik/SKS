//
//  HomeViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 21/07/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class HomeViewController: BaseViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var cityView: UIView!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var favoritesEmptyStackView: UIStackView!
    
    // MARK: - Properties
    
    var selectedIndex: Int = -1
    var sections: [String] = [""]
    let sectionsBuffer: [String] = ["Акции", "Партнеры"]
    
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
    
    var isLoading = false
    
    var offsetPartners = 0
    var limitPartners = 15
    var isPaginationPartners = false
    var isPaginationPartnersLoad = false
    
    var offsetStocks = 0
    var limitStocks = 15
    var isPaginationStocks = false
    var isPaginationStocksLoad = false
    
    var isFirstLoad = true
    
    private lazy var searchViewController: SearchViewController = {
        let storyboard = UIStoryboard(name: "Home", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "\(SearchViewController.self)") as! SearchViewController
        
        viewController.delegate = self
        
        if let height = self.tabBarController?.tabBar.frame.size.height {
            viewController.heightOfTabBar = height
        }
                
        return viewController
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem(title: "Назад", style: .plain, target: nil, action: nil)
        backButton.tintColor = UIColor(hexString: "#333333")
        navigationItem.backBarButtonItem = backButton
        
        setupCategoryCollection()
        getCities()
        //loadData()
        setupTableView()
        setupCityView()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueStock",
            let uuidStock = sender as? String {
            let dvc = segue.destination as! StockViewController
            dvc.uuid = uuidStock
            dvc.city = currentCity
        }
        
        if segue.identifier == "segueNewPartner",
            let uuidStock = sender as? String {
            let dvc = segue.destination as! TestViewController
            dvc.uuidPartner = uuidStock
            dvc.city = currentCity
            dvc.testDelegate = self
        }
    }
    
    private func setupCategoryCollection() {
        categoryCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        categoryCollectionView.register(UINib(nibName: "\(CategoryCollectionViewCell.self)",
                                              bundle: nil),
                                        forCellWithReuseIdentifier: "\(CategoryCollectionViewCell.self)")
        
//        categoryCollectionView.delegate = self
//        categoryCollectionView.dataSource = self
//        categoryCollectionView.reloadData()
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
    

    
    private func getCities() {
        activityIndicator.startAnimating()
        NetworkManager.shared.getCityPartners { [weak self] response in
            if let cities = response.value {
                self?.cities = cities
                self?.picker.source = cities
                
                for city in cities {
                    if city.nameCity == "Петрозаводск" {
                        self?.currentCity = city
                        self?.cityLabel.text = city.nameCity
                        
                        if let name = city.nameCity,
                            let uuid = city.uuidCity {
                            
                            if RememberCity.loadSaved() == nil  {
                                let rememberCity = RememberCity.init()
                                rememberCity.name = name
                                rememberCity.uuidCity = uuid
                                rememberCity.save()
                            }
                        }
                        
                        for (index, value) in cities.enumerated() {
                            if value.nameCity == "Петрозаводск" {
                                self?.picker.picker.selectRow(index,
                                                              inComponent: 0,
                                                              animated: false)
                             }
                        }
                    }
                }
                
                if let rememberCity = RememberCity.loadSaved() {
                    for city in cities {
                        if let name = rememberCity.name,
                            let nameCity = city.nameCity {
                            
                            if name == nameCity {
                                self?.currentCity = city
                                self?.cityLabel.text = city.nameCity
                                
                                for (index, value) in cities.enumerated() {
                                    if let nameCityEn = value.nameCity {
                                        if nameCityEn == name {
                                            self?.picker.picker.selectRow(index,
                                                                          inComponent: 0,
                                                                          animated: false)
                                        }
                                    }

                                }
                            }
                        }
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
        sections = []
        
        if categories.count == 0 { getCategories() }
        if categories.count != 0 {
            partners = []
            stocks = []
            tableView.reloadData()
        }
        
        getPartners()
        getStocks()
        
        activityIndicator.startAnimating()
        dispatchGroup.notify(queue: .main) { [unowned self] in
            
            if self.isFirstLoad {
                self.categoryCollectionView.reloadData()

            }
            self.isFirstLoad = false
            
            self.setupStockTypeImages()
            
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
                self.searchButton.isHidden = false
            } else {
                UIView.transition(with: self.tableView,
                                  duration: 0.2,
                                  options: .transitionCrossDissolve, animations: {
                    self.tableView.reloadData()
                }, completion: nil)
            }
            
            self.isLoading = false
            
            if let selectedCategoty = self.currentUiidCategory,
               selectedCategoty == "favorite" {
                if partners.count == 0 {
                    self.favoritesEmptyStackView.isHidden = false
                } else {
                    self.favoritesEmptyStackView.isHidden = true
                }
            } else {
                self.favoritesEmptyStackView.isHidden = true
            }
        }
    }
    
    private func getCategories() {
        dispatchGroup.enter()
        NetworkManager.shared.getCategories { [weak self] response in
            self?.dispatchGroup.leave()
            if let categories = response.value {
                
                if UserData.loadSaved() != nil {
                    let favoriteCaregory = Category(uuidCategory: "favorite", name: "Избранное", hexcolor: "#F75151", illustrate: "ic_favorite_40")
                    self?.categories.append(favoriteCaregory)
                }
                self?.categories += categories
            }
        }
    }
    
    private func getPartners() {
        dispatchGroup.enter()
        NetworkManager.shared.getPartners(category: currentUiidCategory,
                                          uuidCity: currentCity?.uuidCity,
                                          limit: limitPartners,
                                          offset: offsetPartners) { [unowned self] response in
            self.dispatchGroup.leave()
            if let partners = response.value {
                if partners.count < self.limitPartners {
                    self.isPaginationPartners = true
                }
                self.offsetPartners += self.limitPartners
                
                self.partners = partners
            }
        }
    }
    
    private func getStocks() {
        dispatchGroup.enter()
        NetworkManager.shared.getStocks(category: currentUiidCategory,
                                        uuidCity: currentCity?.uuidCity,
                                        limit: limitStocks,
                                        offset: offsetStocks) { [weak self] response in
            self?.dispatchGroup.leave()
            if let stocks = response.value {
                if stocks.count < self!.limitStocks {
                    self?.isPaginationStocks = true
                }
                self?.offsetStocks += self!.limitStocks
                
                self?.stocks = stocks
                
            }
        }
    }
    
    func setupStockTypeImages() {
        for (index, stock) in stocks.enumerated() {
            if index == 0 {
                stock.typeImage = .orange
            } else {
                switch stocks[index - 1].typeImage {
                case .orange:
                    stocks[index].typeImage = .green
                case .green:
                    stocks[index].typeImage = .blue
                case .blue:
                    stocks[index].typeImage = .purple
                case .purple:
                    stocks[index].typeImage = .orange
                }
            }
        }
    }
    
    private func getPartnersPagination() {
        isPaginationPartnersLoad = true
        activityIndicator.startAnimating()
        NetworkManager.shared.getPartners(category: currentUiidCategory,
                                          uuidCity: currentCity?.uuidCity,
                                          limit: limitPartners,
                                          offset: offsetPartners) { [unowned self] response in
            self.activityIndicator.stopAnimating()
            if let partners = response.value {
                if partners.count < self.limitPartners {
                    self.isPaginationPartners = true
                }
                
                self.partners += partners
                
                let tableOffset = self.offsetPartners + partners.count
                var indexPaths: [IndexPath] = []
                for index in self.offsetPartners..<tableOffset {
                    let indexSection = self.sections.count - 1
                    indexPaths.append(IndexPath(row: index, section: indexSection))
                }
                self.tableView.reloadData()
                
                self.offsetPartners += self.limitPartners
            }
            self.isPaginationPartnersLoad = false
        }
    }
    
    private func getStocksPagination() {
        isPaginationStocksLoad = true
        NetworkManager.shared.getStocks(category: currentUiidCategory,
                                        uuidCity: currentCity?.uuidCity,
                                        limit: limitStocks,
                                        offset: offsetStocks) { [unowned self] response in
            if let stocks = response.value {
                if stocks.count < self.limitStocks {
                    self.isPaginationStocks = true
                }
                self.offsetStocks += self.limitStocks
                
                self.stocks += stocks
                self.tableView.reloadData()
                self.isPaginationStocksLoad = true
            }
        }
    }
    
    private func clearPaginations() {
        offsetStocks = 0
        offsetPartners = 0
        isPaginationPartners = false
        isPaginationStocks = false
    }
    
    func add(asChildViewController viewController: UIViewController) {
        contentView.addSubview(viewController.view)
        viewController.view.frame = contentView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    // MARK: Actions
    
    @objc func cityViewTapped() {
        if isCityTextFieldEditing {
            view.endEditing(true)
            isCityTextFieldEditing = false
        } else {
            cityTextField.becomeFirstResponder()
            isCityTextFieldEditing = true
        }
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        
        searchViewController.currentCity = self.currentCity
        add(asChildViewController: searchViewController)
        contentView.isHidden = false
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource

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
        
        tableView.tableFooterView = UIActivityIndicatorView.init()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if section == 0 { return 1 }
        if section == 0 {
            if stocks.count == 0 {
                return partners.count
            } else {
                return 1
            }
        }
        
        return partners.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.section == 0 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "\(CategoryTableViewCell.self)",
//                                                     for: indexPath) as! CategoryTableViewCell
//
//            cell.setCollectionViewDataSourceDelegate(self)
//            cell.collectionView.tag = 1
//
//            return cell
//        } else
        if indexPath.section == 0 && stocks.count != 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(StockTableViewCell.self)",
                for: indexPath) as! StockTableViewCell

            cell.setCollectionViewDataSourceDelegate(self)
            cell.collectionView.tag = 2

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(PartnerTableViewCell.self)",
                for: indexPath) as! PartnerTableViewCell
            
            cell.model = partners[indexPath.row]
            cell.delegate = self

            if indexPath.row == partners.count - 3 { // last cell
                if !isPaginationPartners &&
                    !isPaginationPartnersLoad { // more items to fetch
                    getPartnersPagination() // increment `fromIndex` by 20 before server call
                }
            }
            
            return cell
        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 ||
            stocks.count == 0 {
            if let uuidPartner = partners[indexPath.row].uuidPartner {
                performSegue(withIdentifier: "segueNewPartner", sender: uuidPartner)
            }
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "\(TitleTableViewHeader.self)") as! TitleTableViewHeader
        header.nameLabel.text = sections[section]
        header.contentView.backgroundColor = .white
        
        return header
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView {
            return categories.count
        } else {
            return stocks.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollectionView {
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

            if indexPath.row == stocks.count - 1 &&
                stocks.count > 1 {
                cell.rightConstraintMainView.constant = 16
            } else {
                cell.rightConstraintMainView.constant = 4
            }
            
            if indexPath.row == stocks.count - 1 { // last cell
                if !isPaginationStocks &&
                    !isPaginationStocksLoad { // more items to fetch
                    getStocksPagination() // increment `fromIndex` by 20 before server call
                }
            }
            
            cell.model = stocks[indexPath.row]

            return cell
        }

        let cell = UICollectionViewCell()
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView.tag == 2 {
            return CGSize(width: view.bounds.width - 12, height: 176 + 40)
        }
        
        if collectionView == categoryCollectionView {
            if indexPath.row == 0 ||
                indexPath.row == categories.count - 1 {
                return CGSize(width: 120, height: 124)
            }
            else {
                return CGSize(width: 108, height: 124)
            }
        }
        
        return CGSize()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            if isLoading { return }
            clearPaginations()
            isLoading = true
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
                if model.isSelected,
                    let hexColor = model.hexcolor {
                    cell.titleLabel.textColor = .white
                    cell.colorView.backgroundColor = UIColor(hexString: "\(hexColor)")
                    
                    cell.mainView.setupShadow(12,
                                              shadowRadius: 6,
                                              color: UIColor.init(hexString: hexColor),
                                              offset: CGSize(width: 0, height: 0),
                                              opacity: 0.30)
                    //cell.mainView.layer.shadowColor = UIColor(hexString: "\(hexColor)").cgColor

                    let newImage = cell.iconImageView.image?.withRenderingMode(.alwaysTemplate)
                    cell.iconImageView.tintColor = .white
                    cell.iconImageView.image = newImage
                } else {
                    cell.colorView.backgroundColor = .white
                    cell.titleLabel.textColor = ColorManager.lightBlack.value
                    cell.mainView.setupShadow(12,
                                         shadowRadius: 7,
                                         color: UIColor.black.withAlphaComponent(0.5),
                                         offset: CGSize(width: 0, height: 0),
                                         opacity: 0.5)
                    //cell.mainView.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor

                    let newImage = cell.iconImageView.image?.withRenderingMode(.alwaysTemplate)
                    cell.iconImageView.image = newImage
                    cell.iconImageView.tintColor = ColorManager.lightBlack.value
                }
            }
        }
    }
}

// MARK: - SKSPickerDelegate

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
                
                if let rememberCity = RememberCity.loadSaved() {
                    rememberCity.name = city.nameCity
                    rememberCity.uuidCity = city.uuidCity
                    rememberCity.save()
                }
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changedCity"),
                                                object: nil,
                                                userInfo: nil)
                break
            }
        }
        
        clearPaginations()
        loadData()
        //currentCity
        
        view.endEditing(true)
    }
    
    func cancelPicker() {
        view.endEditing(true)
    }
}

// MARK: - SearchViewControllerDelegate
 
extension HomeViewController: SearchViewControllerDelegate {
    func detailSearch(value: SearchTableViewCellType) {
        if value.type == .partner {
            performSegue(withIdentifier: "segueNewPartner", sender: value.uuid)
        } else {
            performSegue(withIdentifier: "segueStock", sender: value.uuid)
        }
    }
    
    func cancelButtonTapped() {
        searchViewController.willMove(toParent: nil)
        searchViewController.view.removeFromSuperview()
        searchViewController.removeFromParent()
        
        contentView.isHidden = true
    }
}

// MARK: - PartnerTableViewCellDelegate

extension HomeViewController: PartnerTableViewCellDelegate {
    
    func favoriteButtonTapped(cell: PartnerTableViewCell) {
        if UserData.loadSaved() == nil {
            showAlert(message: "Войдите или зарегистрируйтесь, чтобы добавить партнера в Избранное")
            return
        }
        
        if let indexPath = tableView.indexPath(for: cell) {
            if let isFavorite = partners[indexPath.row].isFavorite {
                if isFavorite {
                    deletePartnerFromFavorite(indexPath: indexPath)
                } else {
                    addPartnerToFavorite(indexPath: indexPath)
                }
            }
        }
    }
    
    private func addPartnerToFavorite(indexPath: IndexPath) {
        guard let uuidPartner = partners[indexPath.row].uuidPartner else { return }
        
        partners[indexPath.row].isFavorite = true
        setStateIsFavoriteButtonForCell(indexPath: indexPath)
        
        NetworkManager.shared.addPartnerToFavorite(uuidPartner: uuidPartner) { _ in }
    }
    
    private func deletePartnerFromFavorite(indexPath: IndexPath) {
        guard let uuidPartner = partners[indexPath.row].uuidPartner else { return }
        
        partners[indexPath.row].isFavorite = false
        
        if let selectedCategoty = currentUiidCategory,
           selectedCategoty == "favorite" {
            partners.remove(at: indexPath.row)
            tableView.reloadData()
            
            if partners.count == 0 {
                favoritesEmptyStackView.isHidden = false
            }
        } else {
            setStateIsFavoriteButtonForCell(indexPath: indexPath)
        }
        
        NetworkManager.shared.deletePartnerFromFavorite(uuidPartner: uuidPartner) { _ in }
    }
    
    private func setStateIsFavoriteButtonForCell(indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? PartnerTableViewCell {
            cell.setStateForFavoriteButton()
        }
    }
    
}

// MARK: - TestViewContollerDelegate

extension HomeViewController: TestViewContollerDelegate {
    
    func favoriteButtonTapped(viewController: TestViewController, isFavorite: Bool, partner: Partner) {
        guard let uuidPartner = partner.uuidPartner else { return }
        
        if let uuidCategory = currentUiidCategory,
           uuidCategory == "favorite" {
            if isFavorite {
                partners.append(partner)
            } else {
                if let index = partners.firstIndex(where: { partner -> Bool in
                    guard let uuid = partner.uuidPartner else { return false }
                    return uuid == uuidPartner
                }) {
                    partners.remove(at: index)
                    if self.partners.count == 0 {
                        self.favoritesEmptyStackView.isHidden = false
                    }
                }
            }
        } else {
            if let partner = partners.first(where: { partner -> Bool in
                guard let uuid = partner.uuidPartner else { return false }
                return uuid == uuidPartner
            }) {
                partner.isFavorite = isFavorite
            }
            
        }
        
        tableView.reloadData()
    }
    
}
