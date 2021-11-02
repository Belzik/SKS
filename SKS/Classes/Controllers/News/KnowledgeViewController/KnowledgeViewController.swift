import UIKit

class KnowledgeViewController: ViewController<KnowledgeView> {
    // MARK: - Properties

    let knowledges: [Knowledge] = [
        .init(title: "Длинное название вопроса или нормативного акта"),
        .init(title: "Длинное название вопроса или нормативного акта"),
        .init(title: "Длинное название вопроса или нормативного акта"),
        .init(title: "Длинное название вопроса или нормативного акта"),
        .init(title: "Длинное название вопроса или нормативного акта"),
        .init(title: "Длинное название вопроса или нормативного акта"),
        .init(title: "Длинное название вопроса или нормативного акта"),
        .init(title: "Длинное название вопроса или нормативного акта"),
    ]

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.setDelegateForTableView(self)
        mainView.backHandler = { [weak self] in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
    }
}
