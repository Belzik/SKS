import UIKit
import SnapKit

class QuestionViewController: ViewController<QuestionView> {
    // MARK: - Properties

    var question: Question?
    var linkToMessenger: String?
    let dispatchGroup = DispatchGroup()

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        getData()
    }

    // MARK: - Private methods

    private func setup() {
        mainView.backHandler = { [weak self] in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }

        mainView.yesHandler = { [weak self] in
            guard let self = self else { return }
            self.mainView.setVotedState(isVoted: true)
            self.sendVote(isUseful: true)
        }

        mainView.noHandler = { [weak self] in
            guard let self = self else { return }
            self.mainView.setVotedState(isVoted: true)
            self.sendVote(isUseful: false)
        }

        mainView.writeHandler = { [weak self] in
            guard let self = self else { return }

            if var link = self.linkToMessenger {
                link = link.replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
                if let url = URL(string: link) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }

    private func getData() {
        mainView.activityIndicatorView.startAnimating()

        getQuestion()
        getLinkToMessage()

        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }

            if let question = self.question {
                self.mainView.setView(withQuestion: question, linkToMessenger: self.linkToMessenger)
            }
            self.mainView.activityIndicatorView.stopAnimating()
        }
    }

    private func getQuestion() {
        guard let uuid = question?.uuidQuestion else { return }

        dispatchGroup.enter()
        NetworkManager.shared.getQuestion(uuid: uuid) { [weak self] result in
            guard let self = self else { return }

            if let question = result.value {
                self.question = question
            }
            self.dispatchGroup.leave()
        }
    }

    private func getLinkToMessage() {
        dispatchGroup.enter()
        NetworkManager.shared.getLinkToMessager { [weak self] result in
            guard let self = self else { return }
            self.linkToMessenger = result.value
            self.dispatchGroup.leave()
        }
    }

    private func sendVote(isUseful: Bool) {
        guard let uuid = question?.uuidQuestion else { return }

        NetworkManager.shared.sendVote(uuid: uuid, isUseful: isUseful) { result in }
    }
}



