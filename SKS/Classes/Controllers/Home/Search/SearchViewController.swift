//
//  SearchViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 15/09/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

protocol SearchViewControllerDelegate: class {
    func detailSearch(value: SearchTableViewCellType)
    func cancelButtonTapped()
}

class SearchViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: TintTextField!
    @IBOutlet weak var bottomConstraintTableView: NSLayoutConstraint!
    
    var timer: Timer = Timer.init()
    let dispatchGroup = DispatchGroup()
    var currentCity: City?
    var stocks: [Stock] = []
    var partners: [Partner] = []
    var searchResult: [SearchTableViewCellType] = []
    
    var heightOfTabBar: CGFloat = 0
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        searchTextField.text = ""

        searchResult = []
        tableView.reloadData()
        
        delegate?.cancelButtonTapped()
    }
    
    weak var delegate: SearchViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
                    
        setupTextField()
        setupImageTextField(textField: searchTextField)
        
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
        searchTextField.becomeFirstResponder()
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                print(heightOfTabBar)
                print(keyboardSize)
                bottomConstraintTableView.constant = keyboardSize.height - heightOfTabBar
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
            bottomConstraintTableView.constant = 0
    }
    
    private func setupTextField() {
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Введите название партнера",
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        searchTextField.returnKeyType = .done
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.tintColor = .white
        
        searchTextField.addTarget(self, action: #selector(textFieldDidchange), for: .editingChanged)
    }
    
    func setupImageTextField(textField: UITextField) {
        let textFieldCGRect = CGRect(x: 0, y: 0, width: 24, height: 24)
        let textFieldImage = UIImage.init()
        let imageView = UIImageView(image: textFieldImage)
        imageView.contentMode = .scaleAspectFit
        
        textField.leftView = imageView
        textField.leftView?.frame = textFieldCGRect
        textField.leftViewMode = .always
    }
    
    func loadData() {
        getPartners()
        //getStocks()
        
        dispatchGroup.notify(queue: .main) { [unowned self] in
            self.searchResult = self.stocks + self.partners

            self.tableView.reloadData()
        }
    }

    func runTimer() {
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { [unowned self] timer in
            self.loadData()
        }
    }
    
    @objc func textFieldDidchange() {
        runTimer()
    }
    
    private func getPartners() {
        dispatchGroup.enter()
        NetworkManager.shared.getPartners(uuidCity: currentCity?.uuidCity,
                                          searchString: searchTextField.text!,
                                          limit: 10,
                                          offset: 0) { [unowned self] response in
            self.dispatchGroup.leave()
            if let partners = response.result.value {
                self.partners = partners
            }
        }
    }
    
    private func getStocks() {
        dispatchGroup.enter()
        NetworkManager.shared.getStocks(uuidCity: currentCity?.uuidCity,
                                        searchString: searchTextField.text!,
                                        limit: 10,
                                        offset: 0) { [unowned self] response in
                                            
            self.dispatchGroup.leave()
            if let stocks = response.result.value {
                self.stocks = stocks
            }
        }
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.register(UINib.init(nibName: "\(SearchTableViewCell.self)",
                                      bundle: nil),
                           forCellReuseIdentifier: "\(SearchTableViewCell.self)")
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(SearchTableViewCell.self)", for: indexPath) as! SearchTableViewCell
        
        cell.model = searchResult[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.detailSearch(value: searchResult[indexPath.row])
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
