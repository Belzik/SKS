//
//  PoolingNewsViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 14/12/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class PoolingNewsViewController: BaseViewController {
    // MARK: - Views

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var endButton: DownloadButton!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var topScrollViewConstraint: NSLayoutConstraint! // 0 или 104
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var dateEndLabel: UILabel!
    @IBOutlet weak var countVotedLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    override var preferredStatusBarStyle: UIStatusBarStyle {
       return .lightContent
    }

    // MARK: - Properties

    var isVoted: Bool = false
    var model: News?
    var selectedIndex: IndexPath?
    var poolingNews: PoolingNews?
    var isEndPooling: Bool = false
    var dispatchGroup = DispatchGroup()
    var user: UserData?

    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let photo = model?.photoUrl?.first,
            photo != "" {
            topScrollViewConstraint.constant = 0
            headerView.isHidden = true
        } else {
            topScrollViewConstraint.constant = 104
            headerView.isHidden = false
        }

        footerView.setupShadow(
            0,
            shadowRadius: 1,
            color: UIColor.black.withAlphaComponent(1),
            offset: CGSize(width: 0, height: 0),
            opacity: 0.3
        )

        calculateAllVotesCount()
        setupTableView()
        getPoolingNews()
        getSingleNews()
        getInfoUser()

        activityIndicatorView.startAnimating()
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.reloadUI()
        }
    }

    // MARK: - Methods

    func getInfoUser() {
        guard let accessToken = UserData.loadSaved()?.accessToken else { return }
        dispatchGroup.enter()
        NetworkManager.shared.getInfoUser { [weak self] response in
            if let user = response.value {
                self?.user = user
            }
            self?.dispatchGroup.leave()
        }
    }

    func reloadUI() {
        self.tableView.reloadData()
        self.tableView.isHidden = false
        self.footerView.isHidden = false
        if UserData.loadSaved() == nil {
            self.endButton.isHidden = true
        } else {
            self.endButton.isHidden = self.isVoted || self.isEndPooling
        }

        self.activityIndicatorView.stopAnimating()
        if self.isVoted {
            self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        }
        if let voted = self.poolingNews?.voted {
            self.countVotedLabel.text = "ОТВЕТИЛИ \(voted) ЧЕЛ."
        }
    }

    func getSingleNews() {
        guard let uuidNews = model?.uuidNews else { return }
        dispatchGroup.enter()
        NetworkManager.shared.getSingleNews(uuidNews: uuidNews) { [weak self] result in
            if let news = result.value {
                self?.model?.content = news.content
            }
            self?.dispatchGroup.leave()
        }
    }

    private func getPoolingNews(fromVote: Bool = false) {
        if !fromVote {
            endButton.isHidden = true
            footerView.isHidden = true
            tableView.isHidden = true
        }
        guard let uuid = model?.uuidNews else { return }
        dispatchGroup.enter()
        NetworkManager.shared.getPoolingNews(uuidNews: uuid) { [weak self] result in
            guard let self = self else { return }
            self.poolingNews = result.value

            if let endPooling = result.value?.endPooling {
                self.dateEndLabel.text = "ОКОНЧАНИЕ " + DateManager.shared.toDateString(date: endPooling)
                if let dateEnd = DateManager.shared.toDatePool(dateString: endPooling) {
                    self.isEndPooling = dateEnd < Date()
                }
            }

            if let voted = self.poolingNews?.userIsVoted {
                self.isVoted = voted
            }

            if fromVote {
                self.reloadUI()
                self.showAlert(message: "Ваш ответ принят")
            }
            self.dispatchGroup.leave()
        }
    }

    func calculateAllVotesCount() {
        if let voted = poolingNews?.voted {
            poolingNews?.voted! += 1
            countVotedLabel.text = "\(voted)"
        }
    }
    
    func sendAnswer() {
        if UserData.loadSaved() == nil {
            showAlert(message: "Для того, чтобы проголосовать необходимо авторизоваться.")
            return
        }

        if let isAllSelected = poolingNews?.isAllSelected(),
           !isAllSelected {
            showAlert(message: "Необходимо ответить на все вопросы.")
            return
        }

        if let userStatus = user?.status,
            let status = ProfileStatus(rawValue: userStatus) {

            if status != .active &&
                status != .activepromo {
                showAlert(message: "Для того, чтобы проголосовать, ваш аккаунт должен быть подтвержден")
                return
            }
        }
        
        guard let request = poolingNews?.makeRequest() else {
            return
        }

        endButton.isDownload = true
        NetworkManager.shared.postPoolingNews(model: request) { [weak self] result in
            if let statusCode = result.responseCode,
                statusCode == 200 {
                self?.getPoolingNews(fromVote: true)
            } else if let statusCode = result.responseCode,
                    statusCode == 409 {
                self?.showAlert(message: "Для того, чтобы проголосовать, ваш аккаунт должен быть подтвержден")
                self?.endButton.isDownload = true
            } else {
                self?.showAlert(message: NetworkErrors.common)
                self?.endButton.isDownload = true
            }

        }
    }

    // MARK: - Actions

    @IBAction func endButtonTapped(_ sender: DownloadButton) {
        sendAnswer()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension PoolingNewsViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.register(UINib(nibName: "\(AnswerTableViewCell.self)",
                                 bundle: nil),
                           forCellReuseIdentifier: "\(AnswerTableViewCell.self)")
        tableView.register(ResultQuestionTableViewCell.self)
        
        tableView.register(UINib(nibName: "\(PoolingTableHeaderView.self)",
                                 bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "\(PoolingTableHeaderView.self)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let question = poolingNews?.questions {
            return question.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isVoted || isEndPooling {
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(ResultQuestionTableViewCell.self)",
                                                     for: indexPath) as! ResultQuestionTableViewCell
            
            if let question = poolingNews?.questions?[indexPath.row] {
                question.countAll = poolingNews?.voted ?? 0
                cell.model = question
            }

            if let questions = poolingNews?.questions {
                if questions.count == (indexPath.row + 1) && isVoted {
                    cell.showEndView(hidden: false)
                } else {
                    cell.showEndView(hidden: true)
                }
            }

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(AnswerTableViewCell.self)",
                                                     for: indexPath) as! AnswerTableViewCell
            
            if let question = poolingNews?.questions?[indexPath.row] {
                cell.model = question
            }
            cell.indexPath = indexPath
            
            return cell
        }

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "\(PoolingTableHeaderView.self)") as! PoolingTableHeaderView

        header.model = self.model
        header.delegate = self
        header.complaintHandler = { [weak self] in
            let vc = ComplaintAboutNewViewController()
            vc.uuidNews = self?.model?.uuidNews
            self?.present(vc, animated: true, completion: nil)
        }

        return header
    }
}

// MARK: - PoolingTableHeaderViewDelegate

extension PoolingNewsViewController: PoolingTableHeaderViewDelegate {
    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
