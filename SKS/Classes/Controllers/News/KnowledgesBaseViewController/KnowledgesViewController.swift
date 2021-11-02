import UIKit

struct Knowledge: KnowledgeTableViewCellSource {
    var title: String
}

protocol KnowledgesViewControllerDelegate: AnyObject {
    func knowledgeTapped(knowledge: Knowledge)
}

class KnowledgesViewController: ViewController<KnowledgesView> {
    // MARK: - Properties

    let knowledges: [Knowledge] = [
        .init(title: "Какие права есть у студента"),
        .init(title: "Обязанности студента"),
        .init(title: "Кто и как защищает интересы студентов в вузе"),
        .init(title: "Стипендия за учебу: государственная академическая стипендия"),
        .init(title: "За что еще можно получать стипендию – иные виды стипендий"),
        .init(title: "Общежития (заселение, права, выселение и т.д.)"),
        .init(title: "Академический отпуск и последипломные каникулы"),
        .init(title: "Отпуск по беременности и родам, уходу"),
    ]
    weak var delegate: KnowledgesViewControllerDelegate?

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.setDelegateForTableView(self)
    }
}
