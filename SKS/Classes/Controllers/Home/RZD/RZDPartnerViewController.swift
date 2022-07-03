import UIKit
import XLPagerTabStrip
import Kingfisher

protocol RZDPartnerScrollableDelegate: AnyObject {
    func scrollViewDidScroll(scrollView: UIScrollView)
}

class RZDPartnerViewController: ButtonBarPagerTabStripViewController {
    // MARK: - IBOutlets

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var controllesContainerView: UIScrollView!

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var logoImageview: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var userLikeImage: UIImageView!
    @IBOutlet weak var complaintButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    // MARK: - Properties

    var aboutRZDProgrammViewController: AboutRZDProgrammViewController?
    var rzdRequestViewController: RZDRequestViewController?
    var commentViewController: CommentViewController?

    var uuidPartner: String = ""
    var uuidCity: String = ""
    var dispatchGroup = DispatchGroup()
    var isLoadingFavorite: Bool = false

    var partner: Partner?
    var comments: [Comment] = []
    var rzdRequest: RzdRequest?
    var ratingStatistic: RatingStatistic?

    // MARK: - View life cycle

    override func viewDidLoad() {
        setupBarButtons()
        super.viewDidLoad()
        loadData()
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
    }

    // MARK: - Methods

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        var  controllers: [UIViewController] = []
        let storyboard = UIStoryboard(name: "Home",
                                      bundle: nil)

        let aboutRZDProgrammViewController = storyboard.instantiateViewController(withIdentifier: "AboutRZDProgrammViewController") as! AboutRZDProgrammViewController
        aboutRZDProgrammViewController.delegate = self
        self.aboutRZDProgrammViewController = aboutRZDProgrammViewController
        controllers.append(aboutRZDProgrammViewController)

        let rzdRequestViewController = storyboard.instantiateViewController(withIdentifier: "RZDRequestViewController") as! RZDRequestViewController
        rzdRequestViewController.delegate = self
        self.rzdRequestViewController = rzdRequestViewController
        controllers.append(rzdRequestViewController)

        let сommentViewController = storyboard.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
        сommentViewController.itemInfo = IndicatorInfo(title: "Отзывы")
        сommentViewController.delegate = self
        self.commentViewController = сommentViewController
        controllers.append(сommentViewController)

        return controllers
    }

    func setupBarButtons() {
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.buttonBarItemFont = UIFont(name: "OpenSans-SemiBold", size: 16)!

        settings.style.selectedBarBackgroundColor = ColorManager.green.value
        settings.style.selectedBarHeight = 2.0

        settings.style.buttonBarMinimumLineSpacing = 12
        settings.style.buttonBarItemTitleColor = ColorManager.green.value
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 16
        settings.style.buttonBarRightContentInset = 16

        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) in
            guard changeCurrentIndex == true else { return }

            oldCell?.label.textColor = ColorManager.lightBlack.value
            newCell?.label.textColor = ColorManager.green.value
        }
    }

    // MARK: - Private methods

    func loadData() {
        activityIndicatorView.startAnimating()

        getPartner()
        getRzdRequest()
        getComments()
        getRatingStatistic()

        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }

            self.activityIndicatorView.stopAnimating()

            self.reloadPagerTabStripView()
            self.reloadData()
            self.layoutUI()
            self.stackView.isHidden = false
            self.controllesContainerView.isHidden = false
            self.buttonBarView.isHidden = false
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

    func getRzdRequest() {
        dispatchGroup.enter()
        NetworkManager.shared.getRzdRequest { [weak self] response in
            self?.dispatchGroup.leave()
            if let rzdRequest = response.value {
                if rzdRequest.status != nil {
                    self?.rzdRequest = rzdRequest
                }
            }
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

    func reloadData() {
        aboutRZDProgrammViewController?.descriptionLabel.text = partner?.description
        rzdRequestViewController?.rzdRequest = rzdRequest
        rzdRequestViewController?.partner = self.partner

        commentViewController?.partner = self.partner
        commentViewController?.ratingStatistic = self.ratingStatistic
        commentViewController?.uuidCity = uuidCity
        commentViewController?.uuidPartner = self.uuidPartner
        commentViewController?.comments = self.comments
    }

    func layoutUI() {
        if let picture = partner?.headerPictures?.first,
            let url = URL(string: picture) {
            bannerImageView.kf.setImage(with: url)
        }

        if let logo = partner?.logo,
           let url = URL(string: logo) {
            logoImageview.kf.setImage(with: url)
        }

        titleLabel.text = partner?.title
        ratingLabel.text = partner?.rating

        categoryLabel.text = partner?.category?.name
        categoryLabel.text = categoryLabel.text?.uppercased()
        setStateFavoriteButtons()

        if UserData.loadSaved() == nil {
            complaintButton.isHidden = true
            favoriteImageView.isHidden = true
        } else {
            complaintButton.isHidden = false
            favoriteImageView.isHidden = false
        }

        if let userRating = ratingStatistic?.userRating {
            if userRating == "false" {
                userLikeImage.image = UIImage(named: "ic_star_empty")
            } else {
                userLikeImage.image = UIImage(named: "ic_star_filled")
            }
        }
    }

    private func setStateFavoriteButtons() {
        if let isFavorite = partner?.isFavorite {
            if isFavorite {
                favoriteImageView.image = UIImage(named: "ic_heart_fill")
            } else {
                favoriteImageView.image = UIImage(named: "ic_heart_empty")
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

    private func addPartnerToFavorite() {
        guard let partner = partner else { return }
        isLoadingFavorite = true
        NetworkManager.shared.addPartnerToFavorite(uuidPartner: uuidPartner) { [weak self] result in
            guard let self = self else { return }
            defer { self.isLoadingFavorite = false }

            if let statucCode = result.responseCode,
               statucCode == 200 {
                self.partner?.isFavorite = true
                NotificationCenter.default.post(name: .favoriteChangeRzd,
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
                NotificationCenter.default.post(name: .favoriteChangeRzd,
                                                object: partner)
                self.setStateFavoriteButtons()
            } else {
                self.showAlert(message: NetworkErrors.common)
            }
        }
    }

    // MARK: - Actions

    @IBAction func tapFavoriteImageView(_ sender: UITapGestureRecognizer) {
        guard let isFavorite = partner?.isFavorite else { return }
        if isLoadingFavorite { return }

        if isFavorite {
            deletePartnerFromFavorite()
        } else {
            addPartnerToFavorite()
        }
    }

    @IBAction func complaintButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "segueComplaint",
                     sender: nil)
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - ServicesAndPricesExecutorViewControllerDelegate

extension RZDPartnerViewController: RZDPartnerScrollableDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        ifScrollDownHideContentView(scrollView: scrollView)
        ifScrollUpShowContentView(scrollView: scrollView)
    }

    private func ifScrollDownHideContentView(scrollView: UIScrollView) {
        let currentTranslationY = scrollView.panGestureRecognizer.translation(in: scrollView).y
        let currentVelocityY =  scrollView.panGestureRecognizer.velocity(in: scrollView.superview).y
        let currentVelocityYSign = Int(currentVelocityY).signum()

        let optimalValueForHideLargeHeaderView: CGFloat = -25 // by experimentally
        if currentVelocityYSign < 0 &&
            currentTranslationY < optimalValueForHideLargeHeaderView {
            if !contentView.isHidden {
                UIView.animate(withDuration: 0.25) {
                  self.contentView.isHidden = true
                }
            }
        }
    }

    private func ifScrollUpShowContentView(scrollView: UIScrollView) {
        let optimalValueForHideLittleHeaderView: CGFloat = -45 // by experimentally
        if scrollView.contentOffset.y < optimalValueForHideLittleHeaderView {
            if contentView.isHidden {
                UIView.animate(withDuration: 0.25) {
                    self.contentView.isHidden = false
                }
            }
        }
    }
}

extension RZDPartnerViewController: CommentViewControllerDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView, tableView: UITableView) {
        scrollViewDidScroll(scrollView: scrollView)
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

extension RZDPartnerViewController: SendCommentViewControllerDelegate {
    func commentSent() {
        commentViewController?.loadData()
    }
}
