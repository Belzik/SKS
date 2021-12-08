import UIKit

class KnowledgeViewController: ViewController<KnowledgeView> {
    // MARK: - Properties

    var questions: [Question] = []
    var knowledge: Knowledge?

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        getQuestions()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueQuestion" {
            let dvc = segue.destination as! QuestionViewController
            if let question = sender as? Question {
                dvc.question = question
            }
        }
    }

    // MARK: - Private methods

    private func setup() {
        mainView.titleLabel.text = knowledge?.name
        mainView.setDelegateForTableView(self)
        mainView.backHandler = { [weak self] in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
    }

    private func getQuestions() {
        guard let uuid = knowledge?.uuidCategory else { return }

        mainView.activityIndicatorView.startAnimating()
        NetworkManager.shared.getKnowledge(uuid: uuid) { [weak self] result in
            guard let self = self else { return }
            self.mainView.activityIndicatorView.stopAnimating()
            if let questions = result.value?.data {
                self.questions = questions
                self.mainView.tableView.reloadData()
            }
        }
    }
}
