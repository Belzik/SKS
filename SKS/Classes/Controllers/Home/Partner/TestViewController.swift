//
//  TestViewController.swift
//  SKS
//
//  Created by Александр Катрыч on 16/11/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Kingfisher

class TestViewController: ButtonBarPagerTabStripViewController {
    //@IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var constraintHeightContentView: NSLayoutConstraint!
    @IBOutlet weak var constraintTopImageView: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightImageView: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var barView: ButtonBarView!
    @IBOutlet weak var derkenedImage: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var acitivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var userLikeImage: UIImageView!
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var complaintButton: UIButton!
    
    @IBOutlet weak var heightOfImageView: NSLayoutConstraint! // 60 или 200
    @IBOutlet weak var topView: UIView!
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func complaintButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "segueComplaint", sender: nil)
    }
    
    var discountViewController: DiscountViewController?
    
    var salePointViewController: SalePointViewController?
    
    var aboutPartnerViewController: AboutPartnerViewController?
    
    var сommentViewController: CommentViewController?
    
    var goingUp: Bool?
    var childScrollingDownDueToParent = false
    var uuidPartner: String = ""
    var city: City?
    var partner: Partner?
    var dispatchGroup = DispatchGroup()
    var salePoints: [SalePoint] = []
    var ratingStatistic: RatingStatistic?
    var comments: [Comment] = []
    
    @IBOutlet weak var backButtonTapped: UIButton!
    @IBOutlet weak var barcodeButtonView: UIView!
    @IBOutlet weak var topLogoConstraint: NSLayoutConstraint! // 16 или 24
    @IBOutlet weak var barcodeButtonGreenView: UIView!
    
    let photosHeader: [String] = []

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.style
    }
    var style: UIStatusBarStyle = .default
    
    override func viewDidLoad() {
        setupView()
        super.viewDidLoad()
        //self.navigationController?.setNavigationBarHidden(true, animated: false)
        scrollView.isHidden = true
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = derkenedImage.frame
        let colors = [
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.9).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        ]

        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.colors = colors

        derkenedImage.layer.addSublayer(gradientLayer)

        let tapBarcodeButton = UITapGestureRecognizer(target: self, action: #selector(tappedBarcodeButton))
        barcodeButtonView.isUserInteractionEnabled = true
        barcodeButtonView.addGestureRecognizer(tapBarcodeButton)
        
        let tapBarcodeButton1 = UITapGestureRecognizer(target: self, action: #selector(tappedBarcodeButton))
        barcodeButtonGreenView.isUserInteractionEnabled = true
        barcodeButtonGreenView.addGestureRecognizer(tapBarcodeButton1)
        
        loadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueComplaint" {
            let dvc = segue.destination as! ComplaintViewController
            dvc.uuidPartner = uuidPartner
        }
        
        if segue.identifier == "segueComment" {
            let dvc = segue.destination as! SendCommentViewController
            dvc.uuidPartner = uuidPartner
            dvc.delegate = self
        }
    }
    
    @objc func tappedBarcodeButton() {
        NetworkManager.shared.upusesPartner(uuidPartner: uuidPartner) { result in
        }
        
        if let tabbarController = tabBarController {
            tabbarController.selectedIndex = 3
        }
    }
    
    private func setupView() {
        if UIDevice.current.type == .iPhone11 ||
            UIDevice.current.type ==  .iPhone11Pro ||
            UIDevice.current.type == .iPhone11ProMax ||
            UIDevice.current.type == .iPhoneX ||
            UIDevice.current.type == .iPhoneXR ||
            UIDevice.current.type == .iPhoneXS ||
            UIDevice.current.type == .iPhoneXSmax {
            constraintHeightContentView.constant = UIScreen.main.bounds.height - 4 * barView.bounds.height //+ 45
            constraintTopImageView.constant = -45
        } else {
            constraintHeightContentView.constant = UIScreen.main.bounds.height - 3 * barView.bounds.height + 20
            constraintTopImageView.constant = -20 //  ЗАМЕНИТЬ на -20
        }
        
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.buttonBarItemFont = UIFont(name: "OpenSans-SemiBold", size: 14)!
        
        settings.style.selectedBarBackgroundColor = ColorManager.green.value
        settings.style.selectedBarHeight = 2.0
        
        settings.style.buttonBarMinimumLineSpacing = 12
        settings.style.buttonBarItemTitleColor = ColorManager.green.value
        settings.style.buttonBarItemsShouldFillAvailableWidth = false
        settings.style.buttonBarLeftContentInset = 16
        settings.style.buttonBarRightContentInset = 16
    
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) in
            guard changeCurrentIndex == true else { return }
            
            oldCell?.label.textColor = ColorManager.lightBlack.value
            newCell?.label.textColor = ColorManager.green.value
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        super.viewWillDisappear(animated)
    }

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        
        let discountViewController = storyboard.instantiateViewController(withIdentifier: "DiscountViewController") as! DiscountViewController
        discountViewController.itemInfo = IndicatorInfo(title: "Скидки и акции")
        discountViewController.delegate = self
        self.discountViewController = discountViewController
        
        let salePointViewController = storyboard.instantiateViewController(withIdentifier: "SalePointViewController") as! SalePointViewController
        salePointViewController.itemInfo = IndicatorInfo(title: "Торговые точки")
        salePointViewController.delegate = self
        self.salePointViewController = salePointViewController
        
        let aboutPartnerViewController = storyboard.instantiateViewController(withIdentifier: "AboutPartnerViewController") as! AboutPartnerViewController
        aboutPartnerViewController.itemInfo = IndicatorInfo(title: "Описание")
        self.aboutPartnerViewController = aboutPartnerViewController
        
        let сommentViewController = storyboard.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
        сommentViewController.itemInfo = IndicatorInfo(title: "Отзывы")
        сommentViewController.delegate = self
        self.сommentViewController = сommentViewController
        
        return [discountViewController, aboutPartnerViewController, salePointViewController, сommentViewController]
    }
    
    func loadData() {
        acitivityIndicatorView.startAnimating()
        
        getSalePoints()
        getPartner()
        getRatingStatistic()
        getComments()
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.acitivityIndicatorView.stopAnimating()
            
            self?.reloadData()
            self?.layoutUI()
            self?.scrollView.isHidden = false
        }
    }
    
    func getComments() {
        dispatchGroup.enter()
        NetworkManager.shared.getComments(uuidPartner: uuidPartner) { [weak self] response in
            self?.dispatchGroup.leave()
            if let comments = response.result.value {
                self?.comments = comments
            }
        }
    }
    
    func getRatingStatistic() {
        dispatchGroup.enter()
        NetworkManager.shared.getRatingStatictis(uuidPartner: uuidPartner) { [weak self] response in
            self?.dispatchGroup.leave()
            if let ratingStatistic = response.result.value {
                self?.ratingStatistic = ratingStatistic
            } else {
                self?.showAlert(message: NetworkErrors.common)
            }
        }
    }
    
    private func getSalePoints() {
        guard let uuidCity = city?.uuidCity else { return }
        
        dispatchGroup.enter()
        NetworkManager.shared.getSalePoints(uuidPartner: uuidPartner,
                                            uuidCity: uuidCity) { [weak self] response in
            self?.dispatchGroup.leave()
            if let salePoints = response.result.value?.points {
                self?.salePoints = salePoints
            } else {
                self?.showAlert(message: NetworkErrors.common)
            }
        }
    }

    private func getPartner() {
        guard let uuidCity = city?.uuidCity else { return }
        
        dispatchGroup.enter()
        NetworkManager.shared.getPartner(uuidPartner: uuidPartner,
                                         uuidCity: uuidCity) { [weak self] response in
            self?.dispatchGroup.leave()
            if let partner = response.result.value {
                self?.partner = partner
            } else {
                self?.showAlert(message: NetworkErrors.common)
            }
        }
    }
    
    func showAlert(actions: [UIAlertAction], title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alertController.addAction($0) }
        present(alertController, animated: true)
    }
    
    func showAlert(message: String) {
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        showAlert(actions: [action], title: "Внимание!", message: message)
    }
    
    func reloadData() {
        discountViewController?.partner = self.partner
        discountViewController?.reloadData()
        
        aboutPartnerViewController?.partner = self.partner
        
        salePointViewController?.partner = self.partner
        salePointViewController?.city = self.city
        salePointViewController?.salePoints = self.salePoints
        
        сommentViewController?.partner = self.partner
        сommentViewController?.ratingStatistic = self.ratingStatistic
        сommentViewController?.comments = self.comments
    }
    
    func layoutUI() {

        if partner?.headerPictures?.first == nil {
            style = .default
        } else {
            style = .lightContent
        }
        setNeedsStatusBarAppearanceUpdate()
        
        
        
        let baseURI = "http://sksapp.px2x.ru"
        
        if let firstHeaderLink = partner?.headerPictures?.first,
            let url = URL(string: firstHeaderLink) {
            derkenedImage.kf.setImage(with: url)
            heightOfImageView.constant = 200
            topLogoConstraint.constant = 16
            topView.isHidden = true
        } else {
            topLogoConstraint.constant = 24
            heightOfImageView.constant = 40 - constraintTopImageView.constant // 80 или 200
            topView.isHidden = false
        }
        
        if let logo = partner?.logo,
            logo != "",
            let url = URL(string: logo) {
            logoImageView.kf.setImage(with: url)
        } else if let logoIllustrate = partner?.category?.illustrate,
            let url = URL(string: baseURI + logoIllustrate) {
            logoImageView.kf.setImage(with: url)
        }
        
        titleLabel.text = partner?.name
        categoryLabel.text = partner?.category?.name
        ratingLabel.text = partner?.rating
        
        if let userRating = ratingStatistic?.userRating {
            if userRating == "false" {
                userLikeImage.image = UIImage(named: "ic_star_empty")
            } else {
                userLikeImage.image = UIImage(named: "ic_star_filled")
            }
        }
        
        if UserData.loadSaved() == nil {
            complaintButton.isHidden = true
        }
    }
}

extension TestViewController: DiscountViewControllerDelegate, SalePointViewControllerDelegate, CommentViewControllerDelegate {    func scrollViewDidScroll(scrollView: UIScrollView, tableView: UITableView) {
        goingUp = scrollView.panGestureRecognizer.translation(in: scrollView).y < 0
        
        let parentViewMaxContentYOffset = self.scrollView.contentSize.height - self.scrollView.frame.height
        
        if goingUp! {
            if scrollView == tableView {
                
                if self.scrollView.contentOffset.y < parentViewMaxContentYOffset && !childScrollingDownDueToParent {
                    self.scrollView.contentOffset.y = max(min(self.scrollView.contentOffset.y + tableView.contentOffset.y, parentViewMaxContentYOffset), 0)
                    tableView.contentOffset.y = 0
                }
            }
        } else {
            if scrollView == tableView {
                if tableView.contentOffset.y < 0 && self.scrollView.contentOffset.y > 0 {
                    self.scrollView.contentOffset.y = max(self.scrollView.contentOffset.y - abs(tableView.contentOffset.y), 0)
                }
            }
            if scrollView == self.scrollView {
                if tableView.contentOffset.y > 0 && self.scrollView.contentOffset.y < parentViewMaxContentYOffset {
                    childScrollingDownDueToParent = true
                    tableView.contentOffset.y = max(tableView.contentOffset.y - (parentViewMaxContentYOffset - self.scrollView.contentOffset.y), 0)
                    self.scrollView.contentOffset.y = parentViewMaxContentYOffset
                    childScrollingDownDueToParent = false
                }
            }
        }
    }
    
    func commentButtonTapped() {
        performSegue(withIdentifier: "segueComment", sender: nil)
    }
}

extension TestViewController: SendCommentViewControllerDelegate {
    func commentSent() {
        сommentViewController?.loadData()
    }
}
//extension TestViewController: UICollectionViewDelegateFlowLayout {
//    func setupCollectionView() {
////        collectionView.delegate = self
////        collectionView.dataSource = self
//        collectionView.register(UINib(nibName: "\(CarPhotosCollectionViewCell.self)",
//                                 bundle: nil),
//                                forCellWithReuseIdentifier: "\(CarPhotosCollectionViewCell.self)")
//

//        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        collectionView.collectionViewLayout.invalidateLayout()
//        collectionView.setNeedsLayout()
//        collectionView.layoutIfNeeded()
//    
//        //collectionView.reloadData()
//    }
//    
//    func setPageControl() {
//        pageControl.numberOfPages = photos.count
//    }
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return photos.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(CarPhotosCollectionViewCell.self)",
//            for: indexPath) as? CarPhotosCollectionViewCell {
//                
//            cell.model = photos[indexPath.row]
//            
//            return cell
//        }
//        
//        return UICollectionViewCell()
//    }
//    
//    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        
//        return CGSize(width: 200,
//                      height: 200)
//
//    }
//}
//
//extension TestViewController: UIScrollViewDelegate {
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        if scrollView is UICollectionView {
//            pageControl?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
//        }
//
//    }
//}
