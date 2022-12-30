//
//  PoolingNewsViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 14/12/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit

class PoolingEventViewController: BaseViewController {
    // MARK: - Views

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var topScrollViewConstraint: NSLayoutConstraint! // 0 или 104
    @IBOutlet weak var eventView: UIView!
    @IBOutlet weak var eventButton: UIButton!
    @IBOutlet weak var eventPlacesCountLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    var footer: PoolingTableFooterView?

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

        eventView.setupShadow(
            0,
            shadowRadius: 1,
            color: UIColor.black.withAlphaComponent(1),
            offset: CGSize(width: 0, height: 0),
            opacity: 0.3
        )

        setupTableView()
        getPoolingNews()
        getSingleNews()
        getInfoUser()

        activityIndicatorView.startAnimating()
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }

            self.activityIndicatorView.stopAnimating()
            if self.isVoted {
                self.tableView.tableFooterView = UIView(frame: CGRect.zero)
            }
            self.tableView.reloadData()
            self.setupEventView()
            self.tableView.isHidden = false
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
            tableView.isHidden = true
        }
        guard let uuid = model?.uuidNews else { return }
        dispatchGroup.enter()
        NetworkManager.shared.getPoolingNews(uuidNews: uuid) { [weak self] result in
            guard let self = self else { return }
            self.poolingNews = result.value

            if let endPooling = result.value?.endPooling {
                if let dateEnd = DateManager.shared.toDatePool(dateString: endPooling) {
                    self.isEndPooling = dateEnd < Date()
                }
            }

            if let voted = self.poolingNews?.userIsVoted {
                self.isVoted = voted
            }

            if fromVote {
                self.footer?.doneButton.isDownload = false
                self.tableView.reloadData()
                self.showAlert(message: "Ваш ответ принят")
            }
            self.dispatchGroup.leave()
        }
    }

    func setupEventView() {
        if model?.event?.uuidEvent != nil {
            eventView.isHidden = false

            if let placeCount = model?.event?.placesCount,
                let placeCountBooked = model?.event?.placesCountBooked {
                eventPlacesCountLabel.text = "\(placeCountBooked)/\(placeCount)"
            }

            if let bookedForMe = model?.event?.bookedForMe {
                if bookedForMe {
                    eventButton.setTitle("ОТМЕНИТЬ РЕГИСТРАЦИЮ", for: .normal)
                    eventButton.setTitleColor(ColorManager.black.value, for: .normal)
                } else {
                    eventButton.setTitle("ЗАРЕГИСТРИРОВАТЬСЯ", for: .normal)
                    eventButton.setTitleColor(ColorManager.green.value, for: .normal)
                }
            }

            if let bookedAccess = model?.event?.bookedAccess,
                !bookedAccess {
                eventButton.isHidden = true
            }
        } else {
            eventView.isHidden = true
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

        guard let request = poolingNews?.makeRequest() else {
            return
        }

        if let userStatus = user?.status,
            let status = ProfileStatus(rawValue: userStatus){
            if status != .active &&
                status != .activepromo {
                showAlert(message: "Для того, чтобы проголосовать, ваш аккаунт должен быть подтвержден")
                return
            }
        }

        footer?.doneButton.isDownload = true
        NetworkManager.shared.postPoolingNews(model: request) { [weak self] result in
            if let statusCode = result.responseCode,
                statusCode == 200 {
                self?.getPoolingNews(fromVote: true)
            } else if let statusCode = result.responseCode,
                    statusCode == 409 {
                self?.showAlert(message: "Для того, чтобы проголосовать, ваш аккаунт должен быть подтвержден")
                self?.footer?.doneButton.isDownload = true
            } else {
                self?.showAlert(message: NetworkErrors.common)
                self?.footer?.doneButton.isDownload = true
            }

        }
    }

    func registrationOnEvent() {
        guard let idEvent = model?.event?.uuidEvent else { return }
        NetworkManager.shared.registrationOnEvent(idEvent: idEvent) { [weak self] result in
            if let statusCode = result.responseCode,
                statusCode == 200 {
                self?.showAlert(
                    title: "Вы зарегистрированы на мероприятие!",
                    message: "Ваша заявка на посещение мероприятия принята. Следите за обновлениями на странице мероприятия.")
                self?.eventButton.setTitle("ОТМЕНИТЬ РЕГИСТРАЦИЮ", for: .normal)
                self?.eventButton.setTitleColor(ColorManager.black.value, for: .normal)
                self?.footer?.contactButton.isHidden = false
                self?.tableView.reloadData()

                if let placeCount = self?.model?.event?.placesCount,
                    let placeCountBooked = self?.model?.event?.placesCountBooked {
                    self?.eventPlacesCountLabel.text = "\(placeCountBooked + 1)/\(placeCount)"
                    self?.model?.event?.placesCountBooked = placeCountBooked + 1
                    self?.model?.event?.bookedForMe = true
                }
            } else if let statusCode = result.responseCode,
                    statusCode == 409 {
                self?.showAlert(message: "Для того, чтобы учавствовать в мероприятии, ваш аккаунт должен быть подтвержден")
           } else {
                self?.showAlert(message: NetworkErrors.common)
           }
        }
    }

    func cancelRegistrationOnEvent() {
        guard let idEvent = model?.event?.uuidEvent else { return }
        NetworkManager.shared.cancelRegistrationOnEvent(idEvent: idEvent) { [weak self] result in
            if let statusCode = result.responseCode,
                statusCode == 200 {
                self?.showAlert(message: "Вы отменили запись на мероприятие")
                self?.eventButton.setTitle("ЗАРЕГИСТРИРОВАТЬСЯ", for: .normal)
                self?.eventButton.setTitleColor(ColorManager.green.value, for: .normal)
                self?.footer?.contactButton.isHidden = true
                self?.tableView.reloadData()

                if let placeCount = self?.model?.event?.placesCount,
                    let placeCountBooked = self?.model?.event?.placesCountBooked {
                    self?.eventPlacesCountLabel.text = "\(placeCountBooked - 1)/\(placeCount)"
                    self?.model?.event?.placesCountBooked = placeCountBooked - 1
                    self?.model?.event?.bookedForMe = false
                }
            } else {
                self?.showAlert(message: NetworkErrors.common)
            }
        }
    }

    // MARK: - Actions

    @IBAction func eventButtonTapped(_ sender: UIButton) {
        if UserData.loadSaved() == nil {
            showAlert(message: "Для того, чтобы зарегистрироваться на мероприятие необходимо авторизоваться.")
            return
        }

        if let title = eventButton.title(for: .normal) {
            if title == "ЗАРЕГИСТРИРОВАТЬСЯ" {
                if let placeCount = model?.event?.placesCount,
                    let placeCountBooked = model?.event?.placesCountBooked,
                    placeCount == placeCountBooked {
                    showAlert(message: "Для того, чтобы зарегистрироваться на мероприятие необходимо авторизоваться.")
                    return
                }

                registrationOnEvent()
            } else {
                cancelRegistrationOnEvent()
            }
        }
    }

    @IBAction func endButtonTapped(_ sender: DownloadButton) {
        sendAnswer()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension PoolingEventViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.register(UINib(nibName: "\(AnswerTableViewCell.self)",
                                 bundle: nil),
                           forCellReuseIdentifier: "\(AnswerTableViewCell.self)")
        tableView.register(ResultQuestionTableViewCell.self)

        tableView.register(UINib(nibName: "\(PoolingEventTableHeaderView.self)",
                                 bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "\(PoolingEventTableHeaderView.self)")

        tableView.register(UINib(nibName: "\(PoolingTableFooterView.self)",
                                 bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "\(PoolingTableFooterView.self)")
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

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "\(PoolingEventTableHeaderView.self)") as! PoolingEventTableHeaderView

        header.model = self.model
        header.delegate = self
        header.complaintHandler = { [weak self] in
            let vc = ComplaintAboutNewViewController()
            vc.uuidNews = self?.model?.uuidNews
            self?.present(vc, animated: true, completion: nil)
        }

        return header
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "\(PoolingTableFooterView.self)") as! PoolingTableFooterView

        if UserData.loadSaved() == nil {
            header.doneButton.isHidden = true
        } else {
            print("-----")
            print(self.isVoted)
            print(self.isEndPooling)
            print("-----")
            header.doneButton.isHidden = self.isVoted || self.isEndPooling
        }

        header.doneHandler = { [weak self] in
            self?.sendAnswer()
        }
        header.contactsHandler = { [weak self] in
            let vc = ContactsEventViewController()
            vc.user = self?.user
            self?.present(vc, animated: true, completion: nil)
        }

        if let bookedForMe = model?.event?.bookedForMe {
            if bookedForMe {
                header.contactButton.isHidden = false
            } else {
                header.contactButton.isHidden = true
            }
        }

        self.footer = header
        return header
    }
}

// MARK: - PoolingTableHeaderViewDelegate

extension PoolingEventViewController: PoolingTableHeaderViewDelegate {
    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
