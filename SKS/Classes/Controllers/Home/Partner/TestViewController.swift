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
import FSPagerView
import Pulley

extension Notification.Name {
    static let favoriteChangeEvent = Notification.Name("FavoriteChangeEvent")
    static let favoriteChangeRzd = Notification.Name("FavoriteChangeRzd")
}
class TestViewController: ButtonBarPagerTabStripViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var constraintHeightContentView: NSLayoutConstraint!
    @IBOutlet weak var constraintTopImageView: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightImageView: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var barView: ButtonBarView!
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var acitivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var userLikeImage: UIImageView!
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var complaintButton: UIButton!
    @IBOutlet weak var federalImageView: UIImageView!

    @IBOutlet weak var heightOfImageView: NSLayoutConstraint! // 60 или 200
    @IBOutlet weak var topView: UIView!
    
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
    
    @IBOutlet weak var backButtonTapped: UIButton! {
        didSet {
            backButtonTapped.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var favoriteView: UIView! {
        didSet {
            favoriteView.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var favoriteImageView: UIImageView!
    
    @IBOutlet weak var topLogoConstraint: NSLayoutConstraint! // 16 или 24
    
    @IBOutlet weak var favotireViewInTopView: UIView!
    @IBOutlet weak var favoriteImageViewInTopView: UIImageView!
    
    // MARK: - Properties
    
    var discountViewController: DiscountViewController?
    
    var salePointViewController: SalePointViewController?
    
    var aboutPartnerViewController: AboutPartnerViewController?
    
    var сommentViewController: CommentViewController?
    
    var goingUp: Bool?
    var childScrollingDownDueToParent = false
    var uuidPartner: String = ""
    var city: City?
    var uuidCity: String = ""
    var partner: Partner?
    var dispatchGroup = DispatchGroup()
    var salePoints: [SalePoint] = []
    var ratingStatistic: RatingStatistic?
    var comments: [Comment] = []
    
    let photosHeader: [String] = []

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.style
    }
    var style: UIStatusBarStyle = .default
    private var isLoadingFavorite: Bool = false
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {

        setupView()
        super.viewDidLoad()
        
        if let uuidCity = city?.uuidCity {
            self.uuidCity = uuidCity
        }

        scrollView.isHidden = true
        
        let tapBarcodeButton = UITapGestureRecognizer(target: self, action: #selector(tappedFavoriteButton))
        favoriteView.isUserInteractionEnabled = true
        favoriteView.addGestureRecognizer(tapBarcodeButton)
        
        let tapBarcodeButton1 = UITapGestureRecognizer(target: self, action: #selector(tappedFavoriteButton))
        favotireViewInTopView.isUserInteractionEnabled = true
        favotireViewInTopView.addGestureRecognizer(tapBarcodeButton1)
        
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewWillAppear(animated)
    }
    
    // MARK: - Segues
    
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
        
        if segue.identifier == "segueMap",
            let salePoint = sender as? SalePoint {
            let dvc = segue.destination as! PulleyPartnerViewController
            
            dvc.salePoint = salePoint
            dvc.partner = self.partner

        }
        
        if segue.identifier == "segueMap",
            let salePoints = sender as? [SalePoint] {
            let dvc = segue.destination as! PulleyPartnerViewController
            
            dvc.salePoints = salePoints
            dvc.partner = self.partner
        }

        if segue.identifier == "segueStock",
            let uuidStock = sender as? String {

            let dvc = segue.destination as! StockViewController
            dvc.uuid = uuidStock
            dvc.city = city
        }
    }
    
    // MARK: - Internal methods
    
    func setupView() {
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
    


    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {

        var  controllers: [UIViewController] = []
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        
        let discountViewController = storyboard.instantiateViewController(withIdentifier: "DiscountViewController") as! DiscountViewController
        discountViewController.itemInfo = IndicatorInfo(title: "Скидки и акции")
        discountViewController.delegate = self
        self.discountViewController = discountViewController
        controllers.append(discountViewController)


        if let isFederalPartner = partner?.isFederalPartner,
            isFederalPartner {
        } else {
            let salePointViewController = storyboard.instantiateViewController(withIdentifier: "SalePointViewController") as! SalePointViewController
            salePointViewController.itemInfo = IndicatorInfo(title: "Торговые точки")
            salePointViewController.delegate = self
            self.salePointViewController = salePointViewController
            controllers.append(salePointViewController)
        }
        
        let aboutPartnerViewController = storyboard.instantiateViewController(withIdentifier: "AboutPartnerViewController") as! AboutPartnerViewController
        aboutPartnerViewController.itemInfo = IndicatorInfo(title: "Описание")
        aboutPartnerViewController.delegate = self
        self.aboutPartnerViewController = aboutPartnerViewController
        controllers.append(aboutPartnerViewController)
        
        let сommentViewController = storyboard.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
        сommentViewController.itemInfo = IndicatorInfo(title: "Отзывы")
        сommentViewController.delegate = self
        self.сommentViewController = сommentViewController
        controllers.append(сommentViewController)
        
        return controllers
    }
    
    func loadData() {
        acitivityIndicatorView.startAnimating()
        
        getSalePoints()
        getPartner()
        getRatingStatistic()
        getComments()
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.acitivityIndicatorView.stopAnimating()

            self?.reloadPagerTabStripView()
            self?.reloadData()
            self?.layoutUI()
            self?.scrollView.isHidden = false
        }
    }
    
    func getComments() {
        dispatchGroup.enter()
        NetworkManager.shared.getComments(uuidPartner: uuidPartner) { [weak self] response in
            self?.dispatchGroup.leave()
            if let comments = response.value {
                self?.comments = comments
            }
        }
    }
    
    func getRatingStatistic() {
        dispatchGroup.enter()
        NetworkManager.shared.getRatingStatictis(uuidPartner: uuidPartner) { [weak self] response in
            self?.dispatchGroup.leave()
            if let ratingStatistic = response.value {
                self?.ratingStatistic = ratingStatistic
            } else {
                self?.showAlert(message: NetworkErrors.common)
            }
        }
    }
    
    func getSalePoints() {
        var latitude = ""
        var longitude = ""
        
        if let location = LocationManager.shared.location {
            latitude = String(describing: location.coordinate.latitude)
            longitude = String(describing: location.coordinate.longitude)
        }
        
        dispatchGroup.enter()
        NetworkManager.shared.getSalePoints(uuidPartner: uuidPartner,
                                            uuidCity: uuidCity,
                                            latitude: latitude,
                                            longitude: longitude) { [weak self] response in
            self?.dispatchGroup.leave()
            if let salePoints = response.value?.points {
                self?.salePoints = salePoints
            } else if let responseCode = response.responseCode,
                      responseCode != 200 {
                self?.showAlert(message: NetworkErrors.common)
            }
        }
    }

    func getPartner() {
        dispatchGroup.enter()
        NetworkManager.shared.getPartner(uuidPartner: uuidPartner,
                                         uuidCity: uuidCity) { [weak self] response in
            self?.dispatchGroup.leave()
            if let partner = response.value {
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
        if let uuidCity = self.city?.uuidCity {
            сommentViewController?.uuidCity = uuidCity
        }
        сommentViewController?.uuidPartner = self.uuidPartner
    }
    
    func layoutUI() {

        if partner?.headerPictures?.first == nil {
            style = .default
        } else {
            style = .lightContent
        }
        setNeedsStatusBarAppearanceUpdate()
        
        let baseURI = NetworkManager.shared.apiEnvironment.baseURI
        
        if let firstHeaderLink = partner?.headerPictures?.first,
           URL(string: firstHeaderLink) != nil {
            
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
            
            if let count = partner?.headerPictures?.count {
                self.pageControl.numberOfPages = count
            }
            
            //derkenedImage.kf.setImage(with: url)
            heightOfImageView.constant = 240
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
        categoryLabel.text = categoryLabel.text?.uppercased()
        
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
            favoriteView.isHidden = true
            favoriteImageViewInTopView.isHidden = true
        }

        if let isFederal = partner?.isFederalPartner {
            federalImageView.isHidden = !isFederal
        }

        setStateFavoriteButtons()
        pagerView.reloadData()
    }
    
    // MARK: - Private methods
    
    private func setStateFavoriteButtons() {
        if let isFavorite = partner?.isFavorite {
            if isFavorite {
                favoriteImageView.image = UIImage(named: "ic_heart_fill")
                favoriteImageViewInTopView.image = UIImage(named: "ic_heart_fill")
            } else {
                favoriteImageView.image = UIImage(named: "ic_heart_empty")
                favoriteImageViewInTopView.image = UIImage(named: "ic_heart_empty")
            }
        } else {
            favoriteView.isHidden = true
            favoriteImageViewInTopView.isHidden = true
        }
    }
    
    private func addPartnerToFavorite() {
        guard let partner = partner else { return }
        isLoadingFavorite = true
        NetworkManager.shared.addPartnerToFavorite(uuidPartner: uuidPartner) { [weak self] result in
            guard let self = self else { return }
            defer { self.isLoadingFavorite = false }
            
            if let statucCode = result.responseCode,
               statucCode == 200 {
                self.partner?.isFavorite = true
                NotificationCenter.default.post(name: .favoriteChangeEvent,
                                                object: partner)
                self.setStateFavoriteButtons()
            } else {
                self.showAlert(message: NetworkErrors.common)
            }
        }
    }
    
    private func deletePartnerFromFavorite() {
        guard let partner = partner else { return }
        
        isLoadingFavorite = true
        NetworkManager.shared.deletePartnerFromFavorite(uuidPartner: uuidPartner) { [weak self] result in
            guard let self = self else { return }
            defer { self.isLoadingFavorite = false }
            
            if let statucCode = result.responseCode,
               statucCode == 200 {
                self.partner?.isFavorite = false
                NotificationCenter.default.post(name: .favoriteChangeEvent,
                                                object: partner)
                self.setStateFavoriteButtons()
            } else {
                self.showAlert(message: NetworkErrors.common)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc func tappedFavoriteButton() {
        if UserData.loadSaved() == nil { return }
        guard let isFavorite = partner?.isFavorite else { return }
        if isLoadingFavorite { return }
        
        if isFavorite {
            deletePartnerFromFavorite()
        } else {
            addPartnerToFavorite()
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func complaintButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "segueComplaint",
                     sender: nil)
    }
    
}

// MARK: - DiscountViewControllerDelegate, SalePointViewControllerDelegate, CommentViewControllerDelegate

extension TestViewController: DiscountViewControllerDelegate, SalePointViewControllerDelegate, CommentViewControllerDelegate, AboutPartnerViewControllerDelegate {
    func stockTapeed(uuid: String) {
        performSegue(withIdentifier: "segueStock", sender: uuid)
    }

    func showSalePoints(salePoints: [SalePoint]) {
        performSegue(withIdentifier: "segueMap", sender: salePoints)
    }
    
    func showSalePoint(salePoint: SalePoint) {
        performSegue(withIdentifier: "segueMap", sender: salePoint)
    }

    func scrollViewDidScroll(someScroll: UIScrollView) {
        goingUp = someScroll.panGestureRecognizer.translation(in: someScroll).y < 0
        let parentViewMaxContentYOffset = self.scrollView.contentSize.height - self.scrollView.frame.height

        if goingUp! {
            if self.scrollView.contentOffset.y < parentViewMaxContentYOffset && !childScrollingDownDueToParent {
                self.scrollView.contentOffset.y = max(min(self.scrollView.contentOffset.y + someScroll.contentOffset.y, parentViewMaxContentYOffset), 0)
                someScroll.contentOffset.y = 0
            }
        } else {
            if someScroll.contentOffset.y < 0 && self.scrollView.contentOffset.y > 0 {
                UIView.animate(withDuration: 0.25) {
                    self.scrollView.contentOffset.y = max(self.scrollView.contentOffset.y - abs(someScroll.contentOffset.y), 0)
                }
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView, tableView: UITableView) {
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
                    UIView.animate(withDuration: 0.25) {
                        self.scrollView.contentOffset.y = max(self.scrollView.contentOffset.y - abs(tableView.contentOffset.y), 0)
                    }
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
    
    func partnerRatingChanged(rating: String) {
        ratingLabel.text = rating
        userLikeImage.image = UIImage(named: "ic_star_filled")
    }
    
}
 
// MARK: - SendCommentViewControllerDelegate
 
extension TestViewController: SendCommentViewControllerDelegate {
    func commentSent() {
        сommentViewController?.loadData()
    }
}

// MARK: - FSPagerViewDataSource, FSPagerViewDelegate

extension TestViewController: FSPagerViewDataSource, FSPagerViewDelegate {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        if let count = partner?.headerPictures?.count {
            return count
        } else {
            return 0
        }
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        
        if let photoUrl = partner?.headerPictures?[index] {
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


