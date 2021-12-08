import UIKit

// MARK: - UITableViewDataSource

extension KnowledgeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as KnowledgeTableViewCell

        cell.model = questions[indexPath.row]

        return cell
    }
}

// MARK: - UITableViewDelegate

extension KnowledgeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "segueQuestion", sender: questions[indexPath.row])
    }
}
