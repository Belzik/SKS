import UIKit
import YandexMobileMetrica

// MARK: - UITableViewDataSource

extension KnowledgesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return knowledges.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as KnowledgeTableViewCell

        cell.model = knowledges[indexPath.row]

        return cell
    }
}

// MARK: - UITableViewDelegate

extension KnowledgesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        YMMYandexMetrica.reportEvent("knowledge.item", parameters: ["id": knowledges[indexPath.row].uuidCategory ?? ""])
        delegate?.knowledgeTapped(knowledge: knowledges[indexPath.row])
    }
}
