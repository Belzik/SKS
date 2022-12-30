//
//  PoolingTableHeaderView.swift
//  SKS
//
//  Created by Александр Катрыч on 14/12/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit
import FSPagerView

class PoolingEventTableHeaderView: UITableViewHeaderFooterView {
    // MARK: - Views

    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var typeNewsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var topImageViewConstraint: NSLayoutConstraint! // -44
    @IBOutlet weak var heightImageView: NSLayoutConstraint! // 200

    @IBOutlet weak var typeNewsView: UIView!
    @IBOutlet weak var typeNewsTextLabel: UILabel!

    @IBOutlet weak var contentLabel: UITextView! {
        didSet {
            contentLabel.textContainerInset = .zero
            contentLabel.contentInset = UIEdgeInsets(top: -4, left: -6, bottom: 0, right: -6)
            contentLabel.dataDetectorTypes = UIDataDetectorTypes.link
        }
    }

    @IBOutlet weak var stackContent: UIStackView!
    @IBOutlet weak var titleEventLabel: UILabel!
    @IBOutlet weak var descriptionEventLabel: UITextView!  {
        didSet {
            descriptionEventLabel.textContainerInset = .zero
            descriptionEventLabel.contentInset = UIEdgeInsets(top: -4, left: -6, bottom: 0, right: -6)
            descriptionEventLabel.dataDetectorTypes = UIDataDetectorTypes.link
        }
    }

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

    @IBOutlet weak var complaintImageView: UIImageView! {
        didSet {
            complaintImageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(complaintImageViewTapped))
            complaintImageView.addGestureRecognizer(tap)
        }
    }

    // MARK: - Properties

    weak var model: News? {
        didSet {
            layoutUI()
        }
    }
    weak var delegate: PoolingTableHeaderViewDelegate?
    var complaintHandler: (() -> Void)?

    // MARK: - Methods

    func layoutUI() {
        pagerView.delegate = self
        pagerView.dataSource = self

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

            topImageViewConstraint.constant = -44
            heightImageView.constant = 224
        } else {
            topImageViewConstraint.constant = 0
            heightImageView.constant = 0
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
                typeNewsTextLabel.text = typeNews
            }
        }

        if let hasPooling = model?.hasEvent,
           hasPooling {
            typeNewsLabel.text = "МЕРОПРИЯТИЕ"
        } else if let hasEvent = model?.hasPooling,
            hasEvent {
            typeNewsLabel.text = "ОПРОС"
        } else {
            typeNewsLabel.text = "НОВОСТЬ"
        }

        titleLabel.text = model?.title

        if let dateString = model?.publishBegin {
            dateLabel.text = DateManager.shared.getDifferenceTime(from: dateString)
        }

        categoryView.layer.cornerRadius = 4

        if UserData.loadSaved() == nil {
            complaintImageView.isHidden = true
        }

        if let htmlString = model?.content {
            contentLabel.text = htmlString.htmlStripped
        }

        if model?.event?.uuidEvent != nil {
            stackContent.setCustomSpacing(24, after: contentLabel)
            stackContent.setCustomSpacing(16, after: titleEventLabel)
            titleEventLabel.text = model?.event?.title
            if let eventHTMl = model?.event?.description {
                descriptionEventLabel.text = eventHTMl.htmlStripped
            }

            titleEventLabel.isHidden = false
            descriptionEventLabel.isHidden = false
        }
    }

    // MARK: - Actions

    @IBAction func backButtonTapped(_ sender: UIButton) {
        delegate?.backButtonTapped()
    }

    @objc func complaintImageViewTapped() {
        complaintHandler?()
    }
}

extension PoolingEventTableHeaderView: FSPagerViewDataSource, FSPagerViewDelegate {
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
