//
//  PoolingNewsViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 14/12/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class PoolingNewsViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var endButton: SKSButton!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var topScrollViewConstraint: NSLayoutConstraint! // 0 или 104
    
    
    @IBAction func endButtonTapped(_ sender: SKSButton) {
        sendAnswer()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
       return .lightContent
    }
    
    var isVoted: Bool = false
    var model: News?
    var selectedIndex: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let voted = model?.pooling?.voted {
            self.isVoted = voted
            endButton.isHidden = voted
            
            if voted {
                tableView.tableFooterView = UIView(frame: CGRect.zero)
            }
        }
        
        if let votedAccess = model?.pooling?.voteAccess {
            if !votedAccess {
                self.isVoted = true
                endButton.isHidden = true
                tableView.tableFooterView = UIView(frame: CGRect.zero)
            }
        }
        
        if let photo = model?.photoUrl?.first,
            photo != "" {
            topScrollViewConstraint.constant = 0
            headerView.isHidden = true
        } else {
            topScrollViewConstraint.constant = 104
            headerView.isHidden = false
        }
        
        calculateAllVotesCount()
        setupTableView()
    }
    
    func calculateAllVotesCount() {
        guard let answerTypes = model?.pooling?.answerTypes else { return }
            
        var allVotesCount = 0
        for answerType in answerTypes {
            if let votes = answerType.votes {
                allVotesCount += votes
            }
        }
        
        for answerType in answerTypes {
            answerType.allVotesCount = allVotesCount
            answerType.isSelected = false
        }
    }
    
    func sendAnswer() {
        if UserData.loadSaved() == nil {
            showAlert(message: "Для того, чтобы проголосовать необходимо авторизоваться.")
            return
        }

        guard let selectedIndex = self.selectedIndex else {
            showAlert(message: "Необходимо выбрать один из вариантов ответов на вопрос")
            return
        }
        
        guard let answerTypes = model?.pooling?.answerTypes,
                let uuidAnswer = answerTypes[selectedIndex.row].uuidAnswerType else { return }
        
        NetworkManager.shared.sendAnswer(idAnswer: uuidAnswer) { [weak self] result in
            if let statusCode = result.responseCode,
                statusCode == 200 {
                self?.showAlert(message: "Ваш ответ принят")
                
                if let votes = answerTypes[selectedIndex.row].votes {
                    answerTypes[selectedIndex.row].votes = votes + 1
                    answerTypes[selectedIndex.row].voted = true
                }
                
                self?.calculateAllVotesCount()
                self?.isVoted = true
                self?.model?.pooling?.voted = true
                self?.tableView.tableFooterView = UIView(frame: CGRect.zero)
                self?.tableView.reloadData()
            } else if let statusCode = result.responseCode,
                    statusCode == 409 {
                self?.showAlert(message: "Для того, чтобы проголосовать, ваш аккаунт должен быть подтвержден")
            } else {
                self?.showAlert(message: NetworkErrors.common)
            }
        }
    }
}

extension PoolingNewsViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.register(UINib(nibName: "\(AnswerTableViewCell.self)",
                                 bundle: nil),
                           forCellReuseIdentifier: "\(AnswerTableViewCell.self)")
        
        tableView.register(UINib(nibName: "\(ResultPoolingTableViewCell.self)",
                                 bundle: nil),
                           forCellReuseIdentifier: "\(ResultPoolingTableViewCell.self)")
        
        tableView.register(UINib(nibName: "\(PoolingTableHeaderView.self)",
                                 bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "\(PoolingTableHeaderView.self)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let answerTypes = model?.pooling?.answerTypes {
            return answerTypes.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isVoted {
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(ResultPoolingTableViewCell.self)",
                                                     for: indexPath) as! ResultPoolingTableViewCell
            
            if let answerTypes = model?.pooling?.answerTypes {
                cell.model = answerTypes[indexPath.row]
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(AnswerTableViewCell.self)",
                                                     for: indexPath) as! AnswerTableViewCell
            
            if let answerTypes = model?.pooling?.answerTypes {
                cell.model = answerTypes[indexPath.row]
            }
            cell.indexPath = indexPath
            cell.delegate = self
            
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isVoted {
            if let selectedIndex = self.selectedIndex {
                if let answerTypes = model?.pooling?.answerTypes {
                    answerTypes[selectedIndex.row].isSelected = false
                    answerTypes[indexPath.row].isSelected = true
                    self.selectedIndex = indexPath
                    
                    tableView.reloadRows(at: [indexPath, selectedIndex], with: .automatic)
                }
            } else {
                self.selectedIndex = indexPath
                if let answerTypes = model?.pooling?.answerTypes {
                    answerTypes[indexPath.row].isSelected = true
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
}

extension PoolingNewsViewController: AnswerTableViewCellDelegate {
    func radioButtonTapped(indexPath: IndexPath) {
        if let selectedIndex = self.selectedIndex {
            if let answerTypes = model?.pooling?.answerTypes {
                answerTypes[selectedIndex.row].isSelected = false
                answerTypes[indexPath.row].isSelected = true
                self.selectedIndex = indexPath
                
                tableView.reloadRows(at: [indexPath, selectedIndex], with: .automatic)
            }
        } else {
            self.selectedIndex = indexPath
            if let answerTypes = model?.pooling?.answerTypes {
                answerTypes[indexPath.row].isSelected = true
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
}

extension PoolingNewsViewController: PoolingTableHeaderViewDelegate {
    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
