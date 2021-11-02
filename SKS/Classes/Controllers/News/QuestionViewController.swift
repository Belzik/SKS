import UIKit

class QuestionViewController: ViewController<QuestionView> {
    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.backHandler = { [weak self] in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
    }
}
