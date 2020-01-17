//
//  CommentViewController.swift
//  SKS
//
//  Created by Alexander on 18/11/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit
import XLPagerTabStrip

protocol CommentViewControllerDelegate: class {
    func scrollViewDidScroll(scrollView: UIScrollView, tableView: UITableView)
    func commentButtonTapped()
}


class CommentViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ratingLabel: UILabel!
    
    var itemInfo = IndicatorInfo(title: "Отзывы")
    weak var delegate: CommentViewControllerDelegate?
    
    var ratingStatistic: RatingStatistic?
    var partner: Partner?
    var comments: [Comment] = []
    
    var header: CommentTableViewHeader?
    
    var dispatchGroup = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(EnableScroll),
                                               name: NSNotification.Name(rawValue: "EnableScroll"),
                                               object: nil)
    }
    
    func loadData() {
        getRatingStatistic()
        getComments()
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            if let statistic = self?.ratingStatistic,
                let partner = self?.partner {
                
                self?.header?.layout(withStatistic: statistic, withPartner: partner)
            }
            
            self?.tableView.reloadData()
        }
    }
    
    func getComments() {
        guard let uuidPartner = partner?.uuid else { return }
        
        dispatchGroup.enter()
        NetworkManager.shared.getComments(uuidPartner: uuidPartner) { [weak self] response in
            self?.dispatchGroup.leave()
            if let comments = response.result.value {
                self?.comments = comments
            }
        }
    }
    
    func getRatingStatistic() {
        guard let uuidPartner = partner?.uuid else { return }
        
        dispatchGroup.enter()
        NetworkManager.shared.getRatingStatictis(uuidPartner: uuidPartner) { [weak self] response in
            self?.dispatchGroup.leave()
            if let ratingStatistic = response.result.value {
                self?.ratingStatistic = ratingStatistic
            }
        }
    }
    
    @objc func EnableScroll() {
       self.tableView.isScrollEnabled = true
    }
    
}

extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.register(UINib(nibName: "\(CommentTableViewCell.self)", bundle: nil),
                           forCellReuseIdentifier: "\(CommentTableViewCell.self)")
        
        tableView.register(UINib(nibName: "\(CommentTableViewHeader.self)", bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "\(CommentTableViewHeader.self)")
        
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(CommentTableViewCell.self)", for: indexPath) as! CommentTableViewCell
        cell.indexPath = indexPath
        cell.delegate = self
        cell.model = comments[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "\(CommentTableViewHeader.self)") as! CommentTableViewHeader
        
        if let statistic = self.ratingStatistic,
            let partner = self.partner {
            
            header.layout(withStatistic: statistic, withPartner: partner)
        }
        header.delegate = self
        self.header = header
        
        return header
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView: scrollView, tableView: tableView)
    }
}


extension CommentViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

extension CommentViewController: CommentTableViewHeaderDelegate {
    func sendCommentButtonTapped() {
        delegate?.commentButtonTapped()
    }
}

extension CommentViewController: CommentTableViewCellDelegate {
    func likeViewTapped(indexPath: IndexPath) {
        if UserData.loadSaved() == nil {
            showAlert(message: "Для того, чтобы поставить лайк необходимо авторизоваться")
        }
        
        guard let uuidComment = comments[indexPath.row].commentInfo?.uuidComment else { return }
        
        NetworkManager.shared.likeComment(uuidComment: uuidComment) { [weak self] result in
            if let toggleLike = result.result.value?.toggleLike {
                if toggleLike == "1" {
                    self?.comments[indexPath.row].commentInfo?.likes! += 1
                    self?.comments[indexPath.row].userLike = "true"
                } else {
                    self?.comments[indexPath.row].commentInfo?.likes! -= 1
                    self?.comments[indexPath.row].userLike = "false"
                }
                self?.tableView.reloadData()
            } else if let statuCode = result.statusCode,
                statuCode == 403 {
                self?.showAlert(message: "Для того, чтобы поставить лайк необходимо статус подтвержденного пользователя")
            } else {
                self?.showAlert(message: NetworkErrors.common)
            }
        }
    }
    
}
