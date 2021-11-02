import UIKit
import SnapKit

class KnowledgesView: SnapKitView {
    // MARK: - Views

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.hideScrollIndicators()
        tableView.register(KnowledgeTableViewCell.self)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = ColorManager._EFF2F5.value

        return tableView
    }()

    // MARK: - Internal methods

    func setDelegateForTableView(_ delegates: UITableViewDelegate & UITableViewDataSource) {
        tableView.delegate = delegates
        tableView.dataSource = delegates
    }

    override func addSubviews() {
        addSubview(tableView)
    }

    override func setConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
