import UIKit
import SnapKit

class NewsDashboardView: SnapKitView {
    // MARK: - Views

    private let navigationView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorManager._383C45.value

        return view
    }()

    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.montserrat.bold.s20
        label.textColor = .white
        label.text = "Новости"

        return label
    }()

    private lazy var tabView: TabView = {
        let newsVC: NewsViewController = UIStoryboard(name: "News", bundle: nil).instantiateViewController(withIdentifier: "NewsViewController") as! NewsViewController
        newsVC.delegate = self

        let knowledgeVC = KnowledgesViewController(isTravel: false)
        knowledgeVC.delegate = self

        let travelVC = KnowledgesViewController(isTravel: true)
        travelVC.delegate = self

        let tabs: [TabElement] = [
            .init(title: "Все новости", count: 3, viewController: newsVC),
            .init(title: "База знаний", count: 0, viewController: knowledgeVC),
            .init(title: "Путешествия", count: 0, viewController: travelVC)
        ]
        let tabView = TabView(tabs: tabs)

        return tabView
    }()

    // MARK: - Properties

    var newsHandler: ((News) -> Void)?
    var knowledgeHandler: ((Knowledge) -> Void)?

    // MARK: - Internal methods

    override func addSubviews() {
        addSubview(navigationView)
        navigationView.addSubview(titleLabel)
        addSubview(tabView)
    }

    override func setConstraints() {
        navigationView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).inset(24)
            $0.top.greaterThanOrEqualToSuperview()
            $0.left.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(20)
        }

        tabView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(navigationView.snp.bottom).offset(4)
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }
    }

    func reloadTabs(countUnreadNews: Int) {
        tabView.customSegmentedControl.changeCountOfItems(count: countUnreadNews)
    }
}

// MARK: - NewsViewControllerDelegate

extension NewsDashboardView: NewsViewControllerDelegate {
    func newsTapped(news: News) {
        newsHandler?(news)
    }
}

// MARK: - KnowledgeBaseViewControllerDelegate

extension NewsDashboardView: KnowledgesViewControllerDelegate {
    func knowledgeTapped(knowledge: Knowledge) {
        knowledgeHandler?(knowledge)
    }
}
