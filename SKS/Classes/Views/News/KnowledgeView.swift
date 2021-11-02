import UIKit
import SnapKit

class KnowledgeView: SnapKitView {
    // MARK: - Views

    private lazy var backView: BackView = {
        let view = BackView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(backTapped))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)

        return view
    }()

    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.montserrat.bold.s20
        label.textColor = ColorManager.lightBlack.value
        label.text = "Кто и как защищает интересы студентов в вузе"
        label.numberOfLines = 0

        return label
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.hideScrollIndicators()
        tableView.register(KnowledgeTableViewCell.self)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = ColorManager._EFF2F5.value

        return tableView
    }()

    // MARK: - Properties
    var backHandler: (() -> Void)?

    // MARK: - Internal methods

    func setDelegateForTableView(_ delegates: UITableViewDelegate & UITableViewDataSource) {
        tableView.delegate = delegates
        tableView.dataSource = delegates
    }

    override func addSubviews() {
        addSubview(backView)
        addSubview(titleLabel)
        addSubview(tableView)
    }

    override func setConstraints() {
        backView.snp.makeConstraints {
            $0.left.equalToSuperview().inset(16)
            $0.top.equalTo(safeAreaLayoutGuide).inset(16)
        }

        titleLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(16)
            $0.top.equalTo(backView.snp.bottom).offset(24)
        }

        tableView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
        }
    }

    // MARK: - Actions

    @objc func backTapped() {
        backHandler?()
    }
}
