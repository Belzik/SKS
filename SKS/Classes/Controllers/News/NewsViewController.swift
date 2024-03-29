//
//  DashboardNewsViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 24/11/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import FSPagerView
import YandexMobileMetrica

protocol NewsViewControllerDelegate: AnyObject {
    func newsTapped(news: News)
}

class NewsViewController: BaseViewController {
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.style
    }
    var style: UIStatusBarStyle = .lightContent

    var news: [News] = []
    
    var offset = 0
    var limit = 15
    var isPaginationEnd = false
    var isPaginationLoad = false
    weak var delegate: NewsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        style = .lightContent
        setupTableView()
        getNews()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueDetailNews" {
            let dvc = segue.destination as! DetailNewsViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                YMMYandexMetrica.reportEvent("news.item", parameters: ["id": news[indexPath.row].uuidNews ?? ""])
                dvc.model = news[indexPath.row]
            }
        }
        
        if segue.identifier == "seguePoolingNews" {
            let dvc = segue.destination as! PoolingNewsViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                YMMYandexMetrica.reportEvent("news.item", parameters: ["id": news[indexPath.row].uuidNews ?? ""])
                dvc.model = news[indexPath.row]
            }
        }
    }
    
    func getNews() {
        isPaginationLoad = true
        activityIndicatorView.startAnimating()
        NetworkManager.shared.getNews(limit: limit,
                                      offset: offset) { [weak self] result in
            guard let self = self else { return }

            self.activityIndicatorView.stopAnimating()
            if let news = result.value {
                if news.count < self.limit {
                    self.isPaginationEnd = true
                }
                
                if news.count == 0
                    && self.news.count == 0 {
                    self.noDataLabel.isHidden = false
                } else {
                    self.noDataLabel.isHidden = true
                    self.news += news
                    self.offset += self.limit
                    self.tableView.reloadData()
                }
            } else {
                self.showAlert(message: NetworkErrors.common)
            }
            self.isPaginationLoad = false
        }
    }
}

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.register(UINib(nibName: "\(NewsTableViewCell.self)",
                                 bundle: nil),
                           forCellReuseIdentifier: "\(NewsTableViewCell.self)")
        
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(NewsTableViewCell.self)", for: indexPath) as! NewsTableViewCell
        cell.model = news[indexPath.row]
        
        if indexPath.row == news.count - 2 {
            if !isPaginationEnd &&
                !isPaginationLoad {
                getNews()
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.newsTapped(news: news[indexPath.row])
    }
}
