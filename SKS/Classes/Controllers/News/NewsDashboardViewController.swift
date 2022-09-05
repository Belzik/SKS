import UIKit

class NewsDashboardViewController: ViewController<NewsDashboardView> {
    // MARK: - Properties

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.style
    }
    private var style: UIStatusBarStyle = .lightContent

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        mainView.newsHandler = { [weak self] news in
            guard let self = self else { return }
            if news.pooling?.uuidPooling != nil {
                self.performSegue(withIdentifier: "seguePoolingNews", sender: news)
            } else {
                self.performSegue(withIdentifier: "segueDetailNews", sender: news)
            }
        }

        mainView.knowledgeHandler = { [weak self] news in
            guard let self = self else { return }
            self.performSegue(withIdentifier: "segueKnowledge", sender: news)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getNumberUnreadNews()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueDetailNews" {
            let dvc = segue.destination as! DetailNewsViewController
            if let news = sender as? News {
                dvc.model = news
            }
        }

        if segue.identifier == "seguePoolingNews" {
            let dvc = segue.destination as! PoolingNewsViewController
            if let news = sender as? News {
                dvc.model = news
            }
        }

        if segue.identifier == "segueKnowledge" {
            let dvc = segue.destination as! KnowledgeViewController
            if let knowledge = sender as? Knowledge {
                dvc.knowledge = knowledge
            }
        }
    }


    // MARK: Methods

    private func getNumberUnreadNews() {
        NetworkManager.shared.getNumberUnreadNessages { [weak self] result in
            self?.setupCountNews(count: result.value?.count)
        }
    }

    private func setupCountNews(count: Int?) {
        if let count = count,
            count > 0 {
            mainView.reloadTabs(countUnreadNews: count)
        } else {
            mainView.reloadTabs(countUnreadNews: 0)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            guard let self = self else { return }
            self.readNews()
        }
    }

    private func readNews() {
        NetworkManager.shared.putReadNews { [weak self] result in
            self?.newsWasReaded()
        }
    }

    private func newsWasReaded() {
        mainView.reloadTabs(countUnreadNews: 0)
        if let vc = tabBarController as? TabBarViewController {
            vc.setupNewsTab(count: 0)
        }
    }
}
