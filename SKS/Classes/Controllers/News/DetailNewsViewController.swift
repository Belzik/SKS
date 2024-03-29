//
//  DetailNewsViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 24/11/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit
import Kingfisher
import FSPagerView
import Kingfisher

class DetailNewsViewController: BaseViewController {
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UITextView! {
        didSet {
            contentLabel.textContainerInset = .zero
            contentLabel.contentInset = UIEdgeInsets(top: -4, left: -6, bottom: 0, right: -6)
            contentLabel.dataDetectorTypes = UIDataDetectorTypes.link
        }
    }
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var scrollBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var topImageViewConstraint: NSLayoutConstraint! // -44
    @IBOutlet weak var heightImageView: NSLayoutConstraint! // 200
    @IBOutlet weak var topScrollViewConstraint: NSLayoutConstraint! // 0 или 104
    
    @IBOutlet weak var eventView: UIView!
    @IBOutlet weak var eventButton: UIButton!
    @IBOutlet weak var eventPlacesCountLabel: UILabel!
    
    @IBOutlet weak var typeNewsView: UIView!
    @IBOutlet weak var typeNewsLabel: UILabel!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            self.pagerView.itemSize = FSPagerView.automaticSize
            self.pagerView.bounces = false
        }
    }
    
    @IBOutlet weak var pageControl: FSPageControl! {
        didSet {
            self.pageControl.contentHorizontalAlignment = .center
            self.pageControl.contentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
    }
    @IBOutlet weak var complaintImageView: UIImageView!
    @IBOutlet weak var contactsButton: DownloadButton!

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

    @IBOutlet weak var stackContent: UIStackView!
    @IBOutlet weak var titleEventLabel: UILabel!
    @IBOutlet weak var contentEventLabel: UITextView! {
        didSet {
            contentEventLabel.textContainerInset = .zero
            contentEventLabel.contentInset = UIEdgeInsets(top: -4, left: -6, bottom: 0, right: -6)
            contentEventLabel.dataDetectorTypes = UIDataDetectorTypes.link
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
       return .lightContent
    }
    
    var model: News?
    var dispatchGroup = DispatchGroup()
    var user: UserData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getInfoUser()
        eventView.setupShadow(0,
                              shadowRadius: 1,
                              color: UIColor.black.withAlphaComponent(1),
                              offset: CGSize(width: 0, height: 0),
                              opacity: 0.3)
        
        getSingleNews()
    }

    func getInfoUser() {
        guard let uuidNews = model?.uuidNews else { return }
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
        activityIndicatorView.startAnimating()
        NetworkManager.shared.getSingleNews(uuidNews: uuidNews) { [weak self] result in
            self?.activityIndicatorView.stopAnimating()
            if let news = result.value {
                self?.model = news
                self?.scrollView.isHidden = false
                self?.headerView.isHidden = false
                self?.eventView.isHidden = false
                self?.layoutUI()
            } else {
                self?.showAlert(message: NetworkErrors.common)
            }
        }
    }
    
    func layoutUI() {
        categoryView.layer.cornerRadius = 4
        
        if let photo = model?.photoUrl?.first,
            photo != "" {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = pagerView.frame
            let colors = [
                UIColor(red: 0, green: 0, blue: 0, alpha: 0.9).cgColor,
                UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
            ]

            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 1)
            gradientLayer.colors = colors

            pagerView.layer.addSublayer(gradientLayer)
            
            if let count = model?.photoUrl?.count {
                self.pageControl.numberOfPages = count
            }
            
            //let url = URL(string: photo)
            //imageView.kf.setImage(with: url)
            
            topImageViewConstraint.constant = -44
            heightImageView.constant = 224
            topScrollViewConstraint.constant = 0
            headerView.isHidden = true
        } else {
            topImageViewConstraint.constant = 0
            heightImageView.constant = 0
            topScrollViewConstraint.constant = 104
            headerView.isHidden = false
        }
        
        typeNewsView.layer.cornerRadius = 4
        if let typeNewsString = model?.typeNews {
            if let type = TypeNews.init(rawValue: typeNewsString) {
                var typeNews = ""
                switch type {
                case .federal:
                    typeNews = "Ф"
                    typeNewsView.backgroundColor = ColorManager.purpleNews.value
                case .region:
                    typeNews = "Р"
                    typeNewsView.backgroundColor = ColorManager.orangeNews.value
                case .university:
                    typeNews = "М"
                    typeNewsView.backgroundColor = ColorManager.blueNews.value
                }
                typeNewsLabel.text = typeNews
            }
        }

        if let hasPooling = model?.hasEvent,
           hasPooling {
            categoryLabel.text = "МЕРОПРИЯТИЕ"
        } else if let hasEvent = model?.hasPooling,
            hasEvent {
            categoryLabel.text = "ОПРОС"
        } else {
            categoryLabel.text = "НОВОСТЬ"
        }
        
        titleLabel.text = model?.title


        if let htmlString = model?.content {
//            contentLabel.attributedText = htmlString.htmlAttributed(family: "OpenSans-Regular", size: 14, color: ColorManager.lightBlack.value)
            print(htmlString)
            contentLabel.text = htmlString.htmlStripped
            //contentLabel.text = htmlString
        }
        
        if let dateString = model?.publishBegin {
            timeLabel.text = DateManager.shared.getDifferenceTime(from: dateString)
        }
        
        if model?.event?.uuidEvent != nil {
            eventView.isHidden = false
            scrollBottomConstraint.constant = 48
            
            if let placeCount = model?.event?.placesCount,
                let placeCountBooked = model?.event?.placesCountBooked {
                eventPlacesCountLabel.text = "\(placeCountBooked)/\(placeCount)"
            }
            
            if let bookedForMe = model?.event?.bookedForMe {
                if bookedForMe {
                    eventButton.setTitle("ОТМЕНИТЬ РЕГИСТРАЦИЮ", for: .normal)
                    eventButton.setTitleColor(ColorManager.black.value, for: .normal)
                    contactsButton.isHidden = false
                } else {
                    eventButton.setTitle("ЗАРЕГИСТРИРОВАТЬСЯ", for: .normal)
                    eventButton.setTitleColor(ColorManager.green.value, for: .normal)
                    contactsButton.isHidden = true
                }
            }
            
            if let bookedAccess = model?.event?.bookedAccess,
                !bookedAccess {
                eventButton.isHidden = true
            }

            stackContent.setCustomSpacing(24, after: contentLabel)
            stackContent.setCustomSpacing(16, after: titleEventLabel)
            titleEventLabel.text = model?.event?.title
            if let eventHTMl = model?.event?.description {
                contentEventLabel.text = eventHTMl.htmlStripped
            }

            titleEventLabel.isHidden = false
            contentEventLabel.isHidden = false
        } else {
            eventView.isHidden = true
            scrollBottomConstraint.constant = 0
            titleEventLabel.isHidden = true
            contentEventLabel.isHidden = true
        }

        if UserData.loadSaved() == nil {
            complaintImageView.isHidden = true
        }
        
        pagerView.reloadData()
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
                self?.contactsButton.isHidden = false
                
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
                self?.contactsButton.isHidden = true
                
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

    @IBAction func contactsButtonTapped(_ sender: DownloadButton) {
        let vc = ContactsEventViewController()
        vc.user = user
        present(vc, animated: true, completion: nil)
    }

    @IBAction func complaintImageViewTapped(_ sender: UITapGestureRecognizer) {
        let vc = ComplaintAboutNewViewController()
        vc.uuidNews = model?.uuidNews
        present(vc, animated: true, completion: nil)
    }
}

extension DetailNewsViewController: FSPagerViewDataSource, FSPagerViewDelegate {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        if let count = model?.photoUrl?.count {
            return count
        } else {
            return 0
        }
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        
        if let photoUrl = model?.photoUrl?[index] {
            let url = URL(string: photoUrl)
            cell.imageView?.kf.setImage(with: url)
        }
        
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        cell.addGestureRecognizer(tap)
        
        return cell
    }
    
    // Заглуша для того, чтобы при тапе на картинку не моргало "черным"
    @objc func cellTapped() {
        return
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        self.pageControl.currentPage = targetIndex
    }
    
    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        self.pageControl.currentPage = pagerView.currentIndex
    }
}

extension UIColor {
    var hexString:String? {
        if let components = self.cgColor.components {
            let r = components[0]
            let g = components[1]
            let b = components[2]
            return  String(format: "%02X%02X%02X", (Int)(r * 255), (Int)(g * 255), (Int)(b * 255))
        }
        return nil
    }
}

extension String {
    var html2Attributed: NSAttributedString? {
        do {
            guard let data = data(using: String.Encoding.utf8) else {
                return nil
            }
            return try NSAttributedString(data: data,
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch {
            print("error: ", error)
            return nil
        }
    }

    var htmlAttributed: (NSAttributedString?, NSDictionary?) {
        do {
            guard let data = data(using: String.Encoding.utf8) else {
                return (nil, nil)
            }

            var dict:NSDictionary?
            dict = NSMutableDictionary()

            return try (NSAttributedString(data: data,
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: &dict), dict)
        } catch {
            print("error: ", error)
            return (nil, nil)
        }
    }

    func htmlAttributed(using font: UIFont, color: UIColor) -> NSAttributedString? {
        do {
            let htmlCSSString = "<style>" +
                "html *" +
                "{" +
                "font-size: \(font.pointSize)pt !important;" +
                "color: #\(color.hexString!) !important;" +
                "font-family: \(font.familyName);" +
                "}</style> \(self)"

            guard let data = htmlCSSString.data(using: String.Encoding.utf8) else {
                return nil
            }

            return try NSAttributedString(data: data,
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch {
            print("error: ", error)
            return nil
        }
    }

    func htmlAttributed(family: String?, size: CGFloat, color: UIColor) -> NSAttributedString? {
        do {
            let htmlCSSString = "<style>" +
                "html *" +
                "{" +
                "font-size: \(size)pt !important;" +
                "color: #\(color.hexString!) !important;" +
                "font-family: \(family ?? "Helvetica");" +
            "}</style> \(self)"

            guard let data = htmlCSSString.data(using: String.Encoding.utf8) else {
                return nil
            }

            return try NSAttributedString(data: data,
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch {
            print("error: ", error)
            return nil
        }
    }

    func stripOutHtml() -> String? {
        do {
            guard let data = self.data(using: .unicode) else {
                return nil
            }
            let attributed = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
            return attributed.string
        } catch {
            return nil
        }
    }

    var htmlStripped : String{
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
