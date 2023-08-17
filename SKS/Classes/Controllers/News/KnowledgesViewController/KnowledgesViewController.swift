import UIKit

protocol KnowledgesViewControllerDelegate: AnyObject {
    func knowledgeTapped(knowledge: Knowledge)
}

class KnowledgesViewController: ViewController<KnowledgesView> {
    // MARK: - Properties

    var knowledges: [Knowledge] = []
    weak var delegate: KnowledgesViewControllerDelegate?
    var isTravel: Bool

    // MARK: - Object life cycle

    init(isTravel: Bool) {
        self.isTravel = isTravel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.setDelegateForTableView(self)

        if UserData.loadSaved() == nil {
            mainView.noAuthLabel.isHidden = false
        } else {
            mainView.noAuthLabel.isHidden = true
            getKnowledges()
        }
    }

    // MARK: - Private methods
    private func getKnowledges() {
        mainView.activityIndicatorView.startAnimating()
        NetworkManager.shared.getKnowledges(isTravel: isTravel) { [weak self] result in
            if let knowledges = result.value?.data {
                self?.knowledges = knowledges
                self?.mainView.tableView.reloadData()
            }
            self?.mainView.activityIndicatorView.stopAnimating()
        }
    }
}
