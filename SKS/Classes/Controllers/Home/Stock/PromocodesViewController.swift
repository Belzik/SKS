import UIKit

class PromocodesViewController: BaseViewController {
    // MARK: UI

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    // MARK: Properties

    var uuid: String = ""
    var getPromocode: GetPromocodeResponse?
    var userPromoHistory: [UserPromoHistory] = []

    // MARK: View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        titleLabel.text = getPromocode?.description
        getData()
    }

    func getData() {
        NetworkManager.shared.userPromoHistory(uuidStock: uuid) { [weak self] result in
            if let value = result.value {
                self?.userPromoHistory = value
            }
            self?.tableView.reloadData()
        }
    }

    func isLast(promo: UserPromoHistory) -> Bool {
        var isLast = false
        let code = UserDefaults.standard.string(forKey: "promocode_value")
        if promo.codeValue == code {
            isLast = true
        }

        return isLast
    }

    // MARK: Actions

    @IBAction override func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

extension PromocodesViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.register(
            UINib(nibName: "\(PromocodeTableViewCell.self)", bundle: nil),
            forCellReuseIdentifier: "\(PromocodeTableViewCell.self)"
        )
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        userPromoHistory.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(PromocodeTableViewCell.self)",
                                                 for: indexPath) as! PromocodeTableViewCell
        cell.titleLabel.text = userPromoHistory[indexPath.row].codeValue
        if isLast(promo: userPromoHistory[indexPath.row]) {
            cell.iconView.image = UIImage(named: "ic_check")
        } else {
            cell.iconView.image = UIImage(named: "ic_copy")
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIPasteboard.general.string = userPromoHistory[indexPath.row].codeValue
        let code = UserDefaults.standard.string(forKey: "promocode_value")
        if code == userPromoHistory[indexPath.row].codeValue { return }
        UserDefaults.standard.set(userPromoHistory[indexPath.row].codeValue, forKey: "promocode_value")
        tableView.reloadData()
    }
}

