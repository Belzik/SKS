import UIKit
import SnapKit

class KnowledgesView: SnapKitView {
    // MARK: - Views

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.hideScrollIndicators()
        tableView.register(KnowledgeTableViewCell.self)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = ColorManager._EFF2F5.value
        tableView.tableFooterView = UIView(frame: .zero)

        return tableView
    }()

    let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView.init(style: .medium)
        activityIndicatorView.hidesWhenStopped = true

        return activityIndicatorView
    }()

    let noAuthLabel: UILabel = {
        let label = UILabel()
        label.text = "Авторизуйся, чтобы посмотреть базу знаний"
        label.font = Fonts.openSans.medium.s16
        label.textColor = ColorManager.lightBlack.value
        label.textAlignment = .center
        label.numberOfLines = 0

        return label
    }()

    // MARK: - Internal methods

    func setDelegateForTableView(_ delegates: UITableViewDelegate & UITableViewDataSource) {
        tableView.delegate = delegates
        tableView.dataSource = delegates
    }

    override func addSubviews() {
        addSubview(tableView)
        addSubview(activityIndicatorView)
        addSubview(noAuthLabel)
    }

    override func setConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        activityIndicatorView.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
        }

        noAuthLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.right.equalToSuperview().inset(16)
        }
    }
}
