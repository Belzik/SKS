import UIKit

protocol KnowledgesViewControllerDelegate: AnyObject {
    func knowledgeTapped(knowledge: Knowledge)
}

class KnowledgesViewController: ViewController<KnowledgesView> {
    // MARK: - Properties

    var knowledges: [Knowledge] = []
    weak var delegate: KnowledgesViewControllerDelegate?

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
        NetworkManager.shared.getKnowledges { [weak self] result in
            if let knowledges = result.value?.data {
                self?.knowledges = knowledges
                self?.mainView.tableView.reloadData()
            }
            self?.mainView.activityIndicatorView.stopAnimating()
        }
    }
}
