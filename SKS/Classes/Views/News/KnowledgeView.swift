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

    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.montserrat.bold.s20
        label.textColor = ColorManager.lightBlack.value
        label.numberOfLines = 0

        return label
    }()

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
        let activityIndicator = UIActivityIndicatorView.init(style: .medium)
        activityIndicator.hidesWhenStopped = true

        return activityIndicator
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
        addSubview(activityIndicatorView)
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

        activityIndicatorView.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
        }
    }

    // MARK: - Actions

    @objc func backTapped() {
        backHandler?()
    }
}
